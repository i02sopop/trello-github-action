#!/usr/bin/env perl

use strict;
use warnings;
use Switch;
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

	if ($event_data->{action} eq "edited") {
		# XXX: Check if the PR has assign a previous card to undo the changes.
	}

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

    if ($event_data->{action} eq "labeled") {
		# If it has the bug label we create a card in Trello.
	}

    if ($event_data->{action} eq "unlabeled") {
		# If we remove the bug label, we need to check if the card needs to be removed.
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
	unless (defined($actor->{id})) {
		my $user_url = "${uri}/users/" . $ENV{'GITHUB_ACTOR'};
		my $user_data = decode_json(`curl -sSL -H "$auth_header" -H "$api_header" "$user_url"`);
		$actor = $trello->searchMember($user_data->{email});
	}
	
	if (defined($actor->{id})) {
		die "Error assigning the card to " . $actor->{username} . "\n"
			unless ($trello->addCardMemberById($card->{id}, $actor->{id}));
	}

	if ($event_data->{action} eq "assigned") {
		# We add the asignee to the card members.
	}

	if ($event_data->{action} eq "unassigned") {
		# We remove the asignee from the card members.
	}

	if ($event_data->{action} eq "review_requested") {
		# We add the reviewer to the card members.
	}

	if ($event_data->{action} eq "review_request_removed") {
		# We remove the reviewer from the card members.
	}

	# Move the card depending on the action.
	switch ($event_data->{action}) {
		case "created" {
			# We move the card to work in progress.
		}
		case "edited" {
			# The edition could add a new link to the card, so we move it to the
			# right state.
		}
		case "opened" {
			# We move the card to move in progress.
		}
		case "reopened" {
			# We move the card to move in progress.
		}
		case "closed" {
			# Check if it's merged or not to move the card to DONE or to TODO.
		}
		case "ready_for_review" {
			# We move the card to the ready for review list if exists.
		}
	}

	exit(-1);
}

# print "Out Environment: " . Dumper(%ENV) . "\n";
my $event_name=$ENV{'GITHUB_EVENT_NAME'};
my $event_data=decode_json(`jq --raw-output . "$ENV{'GITHUB_EVENT_PATH'}"`);
#print "Event data: " . Dumper($event_data) . "\n";

if ($event_name eq 'pull_request') {
	pr_event($event_data);
} else {
	print "Event $event_name without action.\n";
}

# event payload:  Issues
# Activity types:
# - opened
# - edited
# - deleted
# - transferred
# - pinned
# - unpinned
# - closed
# - reopened
# - assigned
# - unassigned
# - labeled
# - unlabeled
# - locked
# - unlocked
# - milestoned
# - demilestoned
# GITHUB_SHA: Last commit on default branch
# GITHUB_REF: Default branch

# Webhook event payload: Project
# Activity types:
# - created
# - updated
# - closed
# - reopened
# - edited
# - deleted
# GITHUB_SHA: Last commit on default branch
# GITHUB_REF: Default branch

# Webhook event payload: project_card
# Activity types:
# - created
# - moved
# - converted to an issue
# - edited
# - deleted
# GITHUB_SHA: Last commit on default branch
# GITHUB_REF: Default branch
