#!/usr/bin/env perl

use strict;
use warnings;
use JSON;
use Data::Dumper;
use Trello;

die "You need to set the trello api key and the api token" unless @ARGV > 2;
my $trello_key = shift;
my $trello_token = shift;

my $trello = Trello->new(
	key   => $trello_key,
	token => $trello_token);

if (defined($ENV{'INPUT_TRELLO_BOARD_ID'})) {
	$trello->board($ENV{'INPUT_TRELLO_BOARD_ID'});
} elsif (defined($ENV{'INPUT_TRELLO_BOARD_NAME'})) {
	$trello->board(trello->searchBoard($ENV{'INPUT_TRELLO_BOARD_NAME'}));
} else {
	die "You have to define the board id or de board name\n";
}

our $uri = 'https://api.github.com';
our $api_header = 'Accept: application/vnd.github.v3+json';
our $auth_header = "Authorization: token $ENV{'GITHUB_TOKEN'}";

sub pr_event {
	my $event_data = shift;

	# Update the trello card with the PR url.
	my $card;
	my ($trello_url) = ($event_data->{pull_request}->{body} =~ m{ (https://trello.com.*) });
	if (defined($trello_url)) {
		$card = $trello->searchCardByShortUrl($trello_url);
	}

	unless (defined($card->{id})) {
		my $title = $event_data->{pull_request}->{title};
		$card = $trello->searchCardByName($title);
	}

	# If we don't have a card we don't have anything to do.
	return unless (defined($card->{id}));

	# Set the github PR in the card information.
	my $link = $event_data->{pull_request}->{_links}->{html}->{href};
	unless ($trello->setCardCustomFieldByName($card->{id}, 'github issue link', "$link")) {
		print "Unable to set the github field\n";
		exit(-1);
	}

	# Assign the trello card to the user that does the PR.
	my $actor = $trello->searchMember($ENV{'GITHUB_ACTOR'});
	if (defined($actor->{id})) {
		die "Error assigning the card to " . $actor->{name} . "\n"
			unless ($trello->addCardMemberById($card->{id}, $actor->{id}));
	}

	my $user_url = "${uri}/users/" . $ENV{'GITHUB_ACTOR'} . "/emails";
	my $user_data = decode_json(`curl -sSL -H "$auth_header" -H "$api_header" "$user_url"`);
	# $user_data->{email}
	print Dumper($user_data);

	# my $url = "${uri}/repos/$ENV{'GITHUB_REPOSITORY'}/pulls";

	# my $comments_url = $event_data->{pull_request}->{comments_url};
	# my $comments = decode_json(`curl -sSL -H "$auth_header" -H "$api_header" "$comments_url"`);
	# print Dumper($event_data->{pull_request});

	# my $ref = $ENV{'GITHUB_REF'}; # something like refs/pull/4/merge.
	# $event_data->{sender}->{id}
	# $event_data->{review_comments_url}
	# $event_data->{labels}
	# $event_data->{merged_by}
	# $event_data->{review_comments}
	# $event_data->{closed_at}

	exit(-1);
}

#print "Out Environment: " . Dumper(%ENV) . "\n";
my $event_name=$ENV{'GITHUB_EVENT_NAME'};
my $event_data=decode_json(`jq --raw-output . "$ENV{'GITHUB_EVENT_PATH'}"`);
# print "Event data: " . Dumper($event_data) . "\n";

if ($event_name eq 'pull_request') {
	pr_event($event_data);
} else {
	print "Event $event_name without action.\n";
}
