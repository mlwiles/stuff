#!/usr/bin/perl

# Michael Wiles - mwiles@us.ibm.com
# 2018/06/10
# vCenter comms

use REST::Client;
use JSON;
# Data::Dumper makes it easy to see what the JSON returned actually looks like 
# when converted into Perl data structures.
use Data::Dumper;
use MIME::Base64;

$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;

my $username = 'mwiles@us.ibm.com';
my $password = 'REDACTED';
my $base64 = encode_base64($username . ':' . $password);
print "Base64:" . $base64 . "\n";

my $client = REST::Client->new();
$client->setHost('https://hostname');

my $headers = {Token => '5ade6d999f397790fa0ddd163b7d182e'};
$client->GET('/rest/vcenter/datacenter', $headers);
print $client->responseCode() . "\n";
print $client->responseContent() . "\n";

my $headers = {Authorization => 'Basic ' . $base64};
$client->POST('/rest/com/vmware/cis/session', $headers);
print $client->responseCode() . "\n";
print $client->responseContent() . "\n";



    
      
      
      
      
      