# Icinga2 AlertOps Integration
AlertOps is an enterprise alert management platform where you can manage incidents, contacts and notifications. This notification script uses the [Generic REST API](http://help.alertops.com/default.aspx/MyWiki/Generic%20REST%20API.html) to send alerts reported by Icinga to your AlertOps account. Based on your ruleset, incidents can be automatically opened and closed, depending whether Icinga reports a problem or a recovery.

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

## Icinga 2 Configuration
### User
The user object defines where your notifications will be sent to. Here you can configure your personal AlertOps API key. Find it in the **Administration -> Subscription Settings** menu. Learn more about user object in the [Icinga Docs](http://docs.icinga.org/icinga2/latest/doc/module/icinga2/chapter/object-types#objecttype-user)
```
object User "alertops" {
  display_name = "AlertOps Notification User"
  groups = [ "icingaadmins" ]
  states = [ OK, Warning, Critical, Unknown ]
  types = [ Problem, Recovery ]

  vars.alertops_apikey = "a2ed82a783te7-4335-h378-0d2a5d1a7b64"
}
```
### NotificationCommand
The notification command defines the location and paremeters of this script. The variables defined here will be used in notification rules later. This command expects the notification script to be located at `/etc/icinga2/scripts/alertops_notification.pl` Learn more about the NotificationCommand object in the [Icinga Docs](http://docs.icinga.org/icinga2/latest/doc/module/icinga2/chapter/object-types#objecttype-notificationcommand)
```
object NotificationCommand "alertops-notification" {
  import "plugin-notification-command"
  command = [ SysconfDir + "/icinga2/scripts/alertops_notification.pl" ]

  env = {
    "ALERTOPS_APIKEY" = "$user.vars.alertops_apikey$"
  }

  arguments = {
          "--source"      = "$alertops_source$",
          "--source_name" = "$alertops_source_name$",
          "--subject"     = "$alertops_subject$",
          "--status"      = "$alertops_state$",
          "--incident"    = "$alertops_incident$",
          "--severity"    = "$alertops_severity$",
          "--url"         = "$alertops_url$",
          "--short_text"  = "$alertops_short_text$",
          "--long_text"   = "$alertops_long_text$",
          "--assignee"    = "$alertops_assignee$"
  }
}
```
### Notifications
The notifications define who will be notified in which case. Also the command is configured here that will be used to send out the notification. Learn more about notifications in the [Icinga Docs](http://docs.icinga.org/icinga2/latest/doc/module/icinga2/chapter/object-types#objecttype-notification) 
#### Services
```
apply Notification "alertops-service" to Service {
  command = "alertops-notification"
  users = [ "alertops" ]
  period = "24x7"
  states = [ OK, Warning, Critical, Unknown ]
  types = [ Problem, Acknowledgement, Recovery ]

  vars.alertops_source = "Icinga2"
  vars.alertops_source_name = "Icinga2-Service"
  vars.alertops_subject = "$host.name$ - $service.name$ - $service.state$"
  vars.alertops_incident = "$host.name$ - $service.name$"
  vars.alertops_long_text = "Service $service.name$ on host $host.name$ is $service.state$!"
  vars.alertops_state = "$service.state$"

  assign where service.vars.notify_alertops == true
}
```
#### Hosts
```
apply Notification "alertops-service" to Service {
  command = "alertops-notification"
  users = [ "alertops" ]
  period = "24x7"
  states = [ OK, Warning, Critical, Unknown ]
  types = [ Problem, Acknowledgement, Recovery ]

  vars.alertops_source = "Icinga2"
  vars.alertops_source_name = "Icinga2-Service"
  vars.alertops_subject = "$host.name$ - $service.name$ - $service.state$"
  vars.alertops_incident = "$host.name$ - $service.name$"
  vars.alertops_long_text = "Service $service.name$ on host $host.name$ is $service.state$!"
  vars.alertops_state = "$service.state$"

  assign where service.vars.notify_alertops == true
}
```

To make a host or service send alerts to AlertOps, simply mark it with this custom variable:
```
vars.notify_alertops = true
```
## AlertOps Configuration
AlertOps expects you to write rulesets to identify your alerts and create incidents based on multiple parameters. These rules are called *Inbound Integrations*. Here are two sample rules for Icinga services and hosts:
### Icinga Host Alerts
| Option                  | Value           | 
| ----------------------- |-----------------|
| Integration Name        | Icinga2 Hosts   |
| Source                  | Icinga2         |
| Source-Name             | Icinga2-Host    |
| Status Field            | SourceStatus    |
| Open Alert on Value     | DOWN            |
| Close Alert on Value    | UP              | 
### Icinga Service Alerts
| Option                  | Value              | 
| ----------------------- |--------------------|
| Integration Name        | Icinga2 Services   |
| Source                  | Icinga2            |
| Source-Name             | Icinga2-Service    |
| Status Field            | SourceStatus       |
| Open Alert on Value     | CRITICAL           |
| Close Alert on Value    | OK                 | 


*See the screenshots for some real use case impressions.*

