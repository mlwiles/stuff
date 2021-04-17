#!/usr/bin/perl

# https://w3.sos.ibm.com/inventory.nsf/access_token.xsp
# Access Token:  ACCESS_TOKEN_HERE
# Token creation date:  Wed Jul 24 14:14:26 GMT 2019
# curl -u "john_doe@us.ibm.com:ACCESS_TOKEN_HERE" "https://w3.sos.ibm.com/inventory.nsf/tracker.xsp?c_code=sos&form=server&page=1&pageSize=10"

# Get list of servers in inventory for a particular c_code
my $curl = `curl -u "mwiles@us.ibm.com:REDACTED" "https://www.sos.ibm.com/inventory.nsf/tracker.xsp?c_code=cfm&form=server&page=1&pageSize=10"`
print { $curl }