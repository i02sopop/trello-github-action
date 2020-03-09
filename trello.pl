#!/usr/bin/env perl

use strict;
use warnings;
use JSON;
use Data::Dumper;
use WWW::Trello::Lite;

# We need at least the trello api key, api token and board id.
die "You need to set the trello api key, api token and board id" unless @ARGV > 2;
my $trello_key = shift;
my $trello_token = shift;
my $trello_board = shift;

our $uri = 'https://api.github.com';
our $api_header = 'Accept: application/vnd.github.v3+json';
our $auth_header = "Authorization: token $ENV{'GITHUB_TOKEN'}";

my $trello = WWW::Trello::Lite->new(
	key   => $trello_key,
	token => $trello_token;

# my $lists = $trello->get( "boards/$id/lists" );
# $trello->post( "cards", {name => 'New card', idList => $id} );

sub pr_event {
	my $event_data = shift;
	my $url = "${uri}/repos/$ENV{'GITHUB_REPOSITORY'}/pulls";


	exit(-1);
}

print "Environment: " . Dumper(%ENV) . "\n";
my $event_name=$ENV{'GITHUB_EVENT_NAME'};
my $event_data=decode_json(`jq --raw-output . "$ENV{'GITHUB_EVENT_PATH'}"`);
print "Event data: " . Dumper($event_data) . "\n";

if ($event_name eq 'pull_request') {
	pr_event($event_data);
} else {
	print "Event $event_name without action.\n";
}
