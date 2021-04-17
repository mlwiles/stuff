#!/usr/bin/perl

# setup instructions 
# https://apps.na.collabserv.com/wikis/home?lang=en-us#!/wiki/Wa225433cd79d_45c0_8599_4034d6251e0e/page/Team%20Processes%20-%20Monitoring%20-%20Zabbix%20-%20Setup%20TIP
#
# actionId::{ACTION.ID}
# actionName::{ACTION.NAME}
# eventDate::{EVENT.DATE}
# eventId::{EVENT.ID}
# eventTags::{EVENT.TAGS}
# eventTime::{EVENT.TIME}
# hostName::{HOSTNAME}
# hostIp::{HOST.IP1}
# itemDescription::{ITEM.DESCRIPTION1}
# itemKey1::{ITEM.KEY1}
# notice::create.notice
# pagerduty::true
# serviceName::wfss-fci
# triggerDescription::{TRIGGER.DESCRIPTION}
# triggerExpression::{TRIGGER.EXPRESSION}
# triggerHostGroupName::{TRIGGER.HOSTGROUP.NAME}
# triggerId::{TRIGGER.ID}
# triggerName::{TRIGGER.NAME}
# triggerSeverity::{TRIGGER.SEVERITY}
# triggerURL::{TRIGGER.URL}

#use JSON;

# web-hook URL, user name, token for TIP
$tip_userAgent="zabbix-tip-alertscript";
$$tip_contentType="application/json";
$tip_token="REDACTED";
#$tip_url="https://tip-oss-flow.test.cloud.ibm.com/hooks/tip-alert";
$tip_url="https://tip-oss-flow.cloud.ibm.com/hooks/tip-alert";
$tip_username="Zabbix Tip Alerting";
$DEBUG = 0;

sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

# some example values #
# $ARGV[0]:50115084d28bd23f957449ec9653dc20
# $ARGV[1]:TIP Trigger
# $ARGV[2]:actionId::8
# actionName::TIP.Action
# eventDate::2019.03.22
# eventId::4716293
# eventTime::23:19:40
# hostName::z4-devops-vvm-wash4
# hostIp::127.0.0.1
# itemDescription::Testing
# itemKey1::vfs.file.exists[/tmp/tiptest]
# triggerDescription::Trigger Description can be as verbose as we want it to be, I would think that we can use this for part of the long description for the Service Now ... blah blah.
# triggerExpression::{z4-devops-vvm-wash4:vfs.file.exists[/tmp/tiptest].last()}=1
# triggerHostGroupName::Zabbix servers
# triggerId::20114
# triggerName::TIPTEST
# triggerSeverity::High
# triggerURL::https://apps.na.collabserv.com/wikis/home?lang=en-us#!/wiki/Wa225433cd79d_45c0_8599_4034d6251e0e/page/Welcome%20to%20FCI%20Cloud%20Ops

# write out to a file to testing the payload and other values
if ($DEBUG) {
   open(my $fh, '>', '/tmp/tip.concern.pl.txt');
   print $fh "\$ARGV[0]:$ARGV[0]\n";
   print $fh "\$ARGV[1]:$ARGV[1]\n";
   print $fh "\$ARGV[2]:$ARGV[2]\n";
}

# split the message that was sent in by CRLF
my %messageOut;
my @messageIn = split /\n/, $ARGV[2];
# further split each value by delimitor '::'
foreach (@messageIn)
{
   trim($_);
   my @values = split('::', $_);
   # $messageOut{"$values[0]"} =  encode_json $values[1];
   # remove the trailing \r
   $values[1] =~ s/\r//g;
   $messageOut{"$values[0]"} =  $values[1];
}

if ($DEBUG) {
   # print out the values to file
   print $fh "##### ----- messageOut values\n";
   foreach (sort keys %messageOut) {
      print $fh "$_ : $messageOut{$_}\n";
   }
}

my %eventTagsOut;
my @eventTagsIn = split /,/, $messageOut{'eventTags'};
# split each eventTag by delimitor ':'
foreach (@eventTagsIn)
{
   trim($_);
   my @values = split(':', $_);
   # remove the trailing \r
   $values[1] =~ s/\r//g;
   $eventTagsOut{"$values[0]"} = $values[1];
}

if ($DEBUG) {
   # print out the values to file
   print $fh "##### ----- eventTags values\n";
   foreach (sort keys %eventTagsOut) {
      print $fh "$_ : $eventTagsOut{$_}\n";
   }
}

if ($DEBUG) { print $fh "\n\n"; }

$alert_id="$messageOut{'triggerId'}.$messageOut{'eventId'}.$messageOut{'actionId'}";
$alert_ui_url="http://z4-devops-vvm-wash4.wfss.ibm.com/zabbix/tr_events.php?triggerid=$messageOut{'triggerId'}&eventid=$messageOut{'eventId'}";
$console="toc";
$crn_cname="wfss-fci";
$crn_ctype="local";
$crn_location="global";
$crn_resource="";
$crn_resource_type="";
$crn_service_instance="wfss-fci-zabbix";
$crn_service_name="$messageOut{'serviceName'}";
$crn_scope="";
$crn_version="v1";
$customer_impacting="false";
$disable_pager= ($messageOut{'pagerduty'} eq "true") ? "false" : "true";
$hostname="$messageOut{'hostName'}";
$ip="$messageOut{'hostIp'}";
$long_description="$messageOut{'triggerName'}:$messageOut{'triggerDescription'}\\\\n";
$long_description.="RunBookURL:";
$long_description.=($messageOut{'triggerURL'} eq "") ? "OPEN GITHUB ISSUE FOR MISSING RUNBOOK URL\\\\n" : "$messageOut{'triggerURL'}\\\\n";
$long_description.="ServiceName:$messageOut{'serviceName'}\\\\n";
$long_description.="MachineName:$messageOut{'hostName'}\\\\n";
$long_description.="MachineIP:$messageOut{'hostIp'}\\\\n";
$long_description.="AlertURL:$alert_ui_url\\\\n";
$long_description.="AlertID:$alert_id\\\\n";
$long_description.="TriggerName:$messageOut{'triggerName'}\\\\n";
$long_description.="TriggerExpression:$messageOut{'triggerExpression'}\\\\n";
$long_description.="Situation:";
$long_description.=($eventTagsOut{'wfss_situation'} eq "") ? "wfss_sit_empty\\\\n" : "$eventTagsOut{'wfss_situation'}\\\\n";
$product_ready_compliance="true";
$runbook_toc_enabled="false";
$runbook_url="$messageOut{'triggerURL'}";
$severity="";
$short_description="$messageOut{'triggerName'} : PROBLEM for $messageOut{'hostName'} : $messageOut{'triggerExpression'}";
$situation= ($eventTagsOut{'wfss_situation'} eq "") ? "wfss_sit_empty" : "$eventTagsOut{'wfss_situation'}";
$source="zabbix";
$timestamp="$messageOut{'eventDate'}.$messageOut{'eventTime'}";
$tip_msg_type="$messageOut{'notice'}";
$tribe_name="wfss-fci";
$version="1.0";

# map severity vaules from Zabbix in a string to required integer for TIP
$switchValue = $messageOut{'triggerSeverity'};
if ($switchValue eq "Information") {
   $severity = "4";
} elsif ($switchValue eq "Average") {
   $severity = "3";
} elsif ($switchValue eq "Warning") {
   $severity = "3";
} elsif ($switchValue eq "High") {
   $severity = "2";
} elsif ($switchValue eq "Disaster") {
   $severity = "1";
} else {
   $severity = "4";
}

#build the payload for the message
$tip_json = "{\"alert_id\":\"$alert_id\",
\"alert_ui_url\":\"$alert_ui_url\",
\"console\":\"$console\",
\"crn\":{
        \"cname\":\"$crn_cname\",
        \"ctype\":\"$crn_ctype\",
        \"location\":\"$crn_location\",
        \"resource\":\"$crn_resource\",
        \"resource_type\":\"$crn_resource_type\",
        \"service_instance\":\"$crn_service_instance\",
        \"service_name\":\"$crn_service_name\",
        \"scope\":\"$crn_scope\",
        \"version\":\"$crn_version\"
        },
\"customer_impacting\":\"$customer_impacting\",
\"disable_pager\":\"$disable_pager\",
\"hostname\":\"$hostname\",
\"ip\":\"$ip\",
\"long_description\":\"$long_description\",
\"runbook_toc_enabled\":\"$runbook_toc_enabled\",
\"runbook_url\":\"$runbook_url\",
\"severity\":$severity,
\"short_description\":\"$short_description\",
\"situation\":\"$situation\",
\"source\":\"$source\",
\"timestamp\":\"$timestamp\",
\"tip_msg_type\":\"$tip_msg_type\",
\"tribe_name\":\"$tribe_name\",\"version\":\"$version\"}";

if ($DEBUG) {
   print $fh "$tip_json\n";
   close $fh;
}

# send the message to the TIP server
system "curl -m 5 -H 'Authorization: $tip_token' -H 'Content-Type: $tip_contentType' -d '$tip_json' -X POST '$tip_url' -A '$tip_userAgent'";