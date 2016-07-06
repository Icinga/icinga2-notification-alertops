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

use version; our $VERSION = qv("1.0");

use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use Data::Dumper;
use Getopt::Long;
use JSON;
use Pod::Usage;

use strict;
use warnings;

my $api_url    = 'https://notify.alertops.com';
my $api_path   = '/RESTAPI.svc/POSTAlertv2/generic/';

my %opts;
my $timeout = 180;
my $debug;
my $help;

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
           'timeout=i'     => \$timeout,
           'help|?'        => \$help,
           'debug'         => \$debug)
or pod2usage("Error parsing command line options\n");

pod2usage(1) if $help;

my $source = $opts{source};
delete $opts{source} or pod2usage ('Argument "source" is required');

my $source_name = $opts{source_name};
pod2usage ('Argument "source_name" is required') if not $source_name;

my $subject = $opts{subject};
pod2usage ('Argument "subject" is required') if not $subject;

my $api_key = $ENV{ALERTOPS_CONTACTPAGER} . "/";
pod2usage ('Environment variable "ALERTOPS_CONTACTPAGER" is required')
if not $api_key;

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

my $fields = join('/', @params);

my $json = encode_json \%opts;
my $req = POST($api_url . $api_path . $api_key . $fields);

$req->header('Content-Type' => 'application/json');
$req->header('Content-Length' => length($json));
$req->content($json);

my $ua = LWP::UserAgent->new;
$ua->agent("AlertOps Icinga2 NotificationCommand/$VERSION");
$ua->timeout($timeout);

my $resp = $ua->request($req);

if ($debug) {
  print "\n- - - -\n";
  print Dumper $req;
  print "\n- - - - - - - -\n";
  print Dumper $resp;
  print "\n- - - -\n";
}

print ('Request failed with code ' . $resp->code . "\n") and exit 2 if ($resp->is_error);

exit 0;

__END__
=head1 NAME

AlertOps Icinga2 NotificationCommand

=head1 SYNOPSIS

./alertops_notification.pl [options]

  **NOTE** It is required to have the environment variable ALERTOPS_CONTACTPAGER
  set to valid AlertOps API key.

  Options:
     --source         **REQUIRED** Notification source (Icinga 2)
     --source_name    **REQUIRED** Source name (ex "production")
     --subject        **REQUIRED** Subject to match AlertOps inbound rule to
                                   (ex "icinga2_alert")
     --status         The Host (UP, DOWN) or Services (OK, WARNING, CRITICAL)
                      exit status
     --incident       An incident reference id
     --severity       AlertOps severity
     --url            A reference URL
     --short_text     Short text describing the issue
     --long_text      A long text describing the issue more verbosely
     --assignee       Name of a AlertOps user
     --timeout        Timeout for the HTTP-REST request, default 180
     --help|?         Print this help message 
     --debug          Debug mode
