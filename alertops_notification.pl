#!/usr/bin/env perl
##
# AlertOps Notification Command
# Copyright (C) 2015 Icinga Development Team (http://www.icinga.org)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation
# Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
##

use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use Data::Dumper;
use Getopt::Long;
use JSON;

my $api_url    = 'http://notify.alertops.com';
my $api_path   = '/RESTAPI.svc/POSTAlertv2/generic/';

my %opts;

GetOptions('source=s'      => \$opts{source}, 
           'source_name=s' => \$opts{source_name},
           'subject=s'     => \$opts{subject},
           'status=s'      => \$opts{status},
           'incident=s'    => \$opts{incident},
           'severity=s'    => \$opts{severity},
           'url=s'         => \$opts{url},
           'short_text=s'  => \$opts{short_text},
           'long_text=s'   => \$opts{long_text},
           'assignee=s'    => \$opts{assignee},
           'debug'         => \$opts{debug})
or die("Error parsing command line options\n");

my $source = $opts{source};
delete $opts{source} or die ('Argument "source" is required');

my $source_name = $opts{source_name};
die('Argument "source_name" is required') if not $source_name;

my $subject = $opts{subject};
die('Argument "source" is required') if not $subject;

my $api_key = $ENV{ALERTOPS_CONTACTPAGER};
die('Environment variable "ALERTOPS_CONTACTPAGER" is required') if not $api_key;

my $debug = delete $opts{debug};

my @params = (
  $source,                                   # Soure
  "source_name",                             # Source Name
  "subject",                                 # Subject key
  $opts{incident}   ? "incident"   : "NONE", # Incident id key
  $opts{status}     ? "status"     : "NONE", # Status key
  $opts{severity}   ? "severity"   : "NONE", # Severity key
  $opts{url}        ? "url"        : "NONE", # Url key
  $opts{short_text} ? "short_text" : "NONE", # Short text key
  $opts{long_text}  ? "long_text"  : "NONE", # Long text key
  $opts{assignee}   ? "assignee"   : "NONE"  # Assignee key
);

my $fields;

for my $param (@params) {
  $fields .= "/$param";
}

my $json = encode_json \%opts;
my $req = POST($api_url . $api_path . $api_key . $fields);

$req->header( 'Content-Type' => 'application/json' );
$req->content( $json );

my $ua = LWP::UserAgent->new;
my $resp = $ua->request($req);

if ($debug) {
  print Dumper $req;
  print "\n- - - -\n";
  print Dumper $resp;
  print "\n- - - -\n";
}
