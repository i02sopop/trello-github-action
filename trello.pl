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
	$trello->board = $ENV{'INPUT_TRELLO_BOARD_ID'};
} elsif (defined($ENV{'INPUT_TRELLO_BOARD_NAME'})) {
	$trello->board = trello->searchBoard($ENV{'INPUT_TRELLO_BOARD_NAME'});
} else {
	die "You have to define the board id or de board name\n";
}

our $uri = 'https://api.github.com';
our $api_header = 'Accept: application/vnd.github.v3+json';
our $auth_header = "Authorization: token $ENV{'GITHUB_TOKEN'}";

# sub pr_event {
# 	my $event_data = shift;
# 	my $url = "${uri}/repos/$ENV{'GITHUB_REPOSITORY'}/pulls";


# 	exit(-1);
# }

print "Environment: " . Dumper(%ENV) . "\n";
my $event_name=$ENV{'GITHUB_EVENT_NAME'};
my $event_data=decode_json(`jq --raw-output . "$ENV{'GITHUB_EVENT_PATH'}"`);
print "Event data: " . Dumper($event_data) . "\n";

# if ($event_name eq 'pull_request') {
# 	pr_event($event_data);
# } else {
# 	print "Event $event_name without action.\n";
# }
