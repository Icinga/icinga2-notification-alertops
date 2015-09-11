#!/usr/bin/env perl

use warnings;

use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use Data::Dumper;
use Getopt::Long;

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

my @params = (
  'Icinga',           # Soure
  'Icinga',           # Source Name
  'subjectKey',       # Subject key
  'NONE',             # Incident id key
  $state,             # Status key
  'NONE',             # Severity key
  'NONE',             # Url key
  'NONE',             # Short text key
  'NONE',             # Long text key
  'NONE'              # Assignee key
);

my $fields;

for my $param (@params) {
  $fields .= "/$param";
}

my $req = POST($api_url . $api_path . $api_key . $fields);

my $ua = LWP::UserAgent->new;
my $resp = $ua->request($req);

print Dumper $req;
print "\n- - - -\n";
print Dumper $resp;
print "\n- - - -\n";
