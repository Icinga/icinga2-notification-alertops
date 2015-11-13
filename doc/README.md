# AlertOps Icinga 2 Integration

## Prerequisites

### Perl packages

This libraries are used by this notification command:

* HTTP::Request::Common
* LWP::UserAgent
* JSON

If you using debian for example, install the following packages:

    # apt-get install -y libhttp-message-perl libwww-perl libjson-perl

There is a cpan minus dependencies file in the root filter (cpanfile). You can
install the dependencies with the following command:

    # cpanm --verbose --installdeps .

Icinga 2 can send alerts to AlertOps using the [Generic REST API](http://help.alertops.com/default.aspx/MyWiki/Generic%20REST%20API.html).
AlertOps will open a new incident when an alert is received from Icinga.
AlertOps will close the same incident when it recovers.

## Icinga 2 Configuration
Consult the [Icinga 2 documentation](http://docs.icinga.org/icinga2/latest/doc)
for more information on how to configure a [Notification](http://docs.icinga.org/icinga2/latest/doc/module/icinga2/chapter/monitoring-basics#notifications)
in Icinga 2.

## AlertOps Configuration
Refer to the Generic REST API topic for detauls on configuration options for
Mapping Rules.

_see screenshots_

