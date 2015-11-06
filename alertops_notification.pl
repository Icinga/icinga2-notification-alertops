#!/usr/bin/env perl

use warnings;

use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use Data::Dumper;
use Getopt::Long;
use JSON;

my $api_url    = 'http://notify.alertops.com';
my $api_path   = '/RESTAPI.svc/POSTAlertv2/generic/';

my $opts;

GetOptions('object=s' => \$opts->{object});
my $object = $opts->{object};

sub getEnvs {
  my %envs;

  while ((my $k, my $v) = each %ENV) {
    next unless $k =~ /^ALERTOPS_(.*)$/;
    $envs{$1} = $v;
  }

  return %envs;
}

my %data = getEnvs;

my $api_key = $data{'CONTACTPAGER'}; # API KEY

my $state = $data{'HOSTSTATE'};
$state = $data{'SERVICESTATE'} if ($object eq 'service');

my %json_hash = ('subject', $data{'SUBJECT'});

my $incident_key = 'NONE';
if ($data{'INCIDENT'}) {
	$incident = 'incident';
	$json_hash{'incident'} = $data{'INCIDENT'};
}

my $severity_key = 'NONE';
if ($data{'SEVERITY'}) {
	$severity = 'severity';
	$json_hash{'severity'} = $data{'SEVERITY'};
}

my $url_key = 'NONE';
if ($data{'URL'}) {
	$url_key = 'url';
	$json_hash{'url'} = $data{'URL'};
}

my $short_text = 'NONE';
if ($data{'SHORTMSG'}) {
	$short_text = 'short_text';
	$json_hash{'short_text'} = $data{'SHORTMSG'};
}

my $long_text = 'NONE';
if ($data{'LONGMSG'}) {
	$long_text = 'long_text';
	$json_hash{'long_text'} = $data{'LONGMSG'};
}

my $assignee_key = 'NONE';
if ($data{'ASSIGNEE'}) {
	$url_key = 'assignee';
	$json_hash{'assignee'} = $data{'ASSIGNEE'};
}

my @params = (
  'Icinga',           # Soure
  'Icinga',           # Source Name
  'subject',          # Subject key
  $incident_key,      # Incident id key
  $state,             # Status key
  $severity_key,      # Severity key
  $url_key,           # Url key
  $short_text,        # Short text key
  $long_text,         # Long text key
  $assignee_key       # Assignee key
);

my $fields;

for my $param (@params) {
  $fields .= "/$param";
}

my $json = encode_json \%json_hash;
my $req = POST($api_url . $api_path . $api_key . $fields);
$req->header( 'Content-Type' => 'application/json' );
$req->content( $json );

my $ua = LWP::UserAgent->new;
my $resp = $ua->request($req);

print Dumper $req;
print "\n- - - -\n";
print Dumper $resp;
print "\n- - - -\n";
