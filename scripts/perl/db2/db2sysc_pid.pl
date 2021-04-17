#!/usr/bin/perl

# mwiles@us.ibm.com - 2018-09-13
# this is used to collect data for process and also create a file if certain
# CPU percentage is passed

sub getLoggingTime {
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    $nice_timestamp = sprintf ( "%04d%02d%02d %02d:%02d:%02d",
                                   $year+1900,$mon+1,$mday,$hour,$min,$sec);
    return $nice_timestamp;
}

$DEBUG = $ARGV[0];                                                    #passed in for debug
$FILENAME_HIGH = "/tmp/DB2HighCPU.log";                               #file used to trigger Zabbix
$FILENAME_NORM = "/tmp/DB2CPU.log";                                   #log file for data
$MAXSIZE = 500000;                                                    #max size (in bytes) of log file before backup
$HIGHCPU = 90;                                                        #percentage of CPU usage that causes concern
$PROCESS = "db2sysc";                                                 #name of the process to check for
$USERNAME = "db2inst1";                                               #owner of the process 
$TRYRECOVERY = 1;                                                     #try to programatically recover?
$RECOVERYCMD = "sudo -i -u db2inst1 /home/db2inst1/db2sysc_conn.sh";  #recover command

#open the file for logging
open($fh, '-|', "top -b -n 1 | grep $PROCESS | grep $USERNAME") or die $!;
while ($pslist = <$fh>) {
  if ($DEBUG) { print "pslist:$pslist"; }

  #collect the relevant data
  @parts = split ' ', $pslist;
  $cpu = $parts[8];
  $mem = $parts[9];
  if ($DEBUG) { print "cpu:$cpu\n"; }

  $timestamp = getLoggingTime();

  #normal logging of values
  $filename = $FILENAME_NORM;
  open($file_norm, '>>', $filename) or die "Could not open file '$filename2' $!";
  $normcpu = "$timestamp -- CPU:$cpu,MEM:$mem\n";
  print $file_norm "$normcpu";
  if ($DEBUG) { print "normcpu:$normcpu"; }
  close $file_norm;

  #create file to setoff alarm
  if ($cpu > $HIGHCPU) {
     $filename = $FILENAME_HIGH;
     open($file_high, '>>', $filename) or die "Could not open file '$filename' $!";
     $line = "$timestamp -- CPU:$cpu,MEM:$mem\n";
     print $file_high "$line";
     if ($DEBUG) { print "highcpu:$line"; }
     close $file_high;

     if ($TRYRECOVERY) {
       open($recovery, '-|', "$RECOVERYCMD") or die $!;
       if ($DEBUG) { print "recovery:$RECOVERYCMD\n"; }
       print $file_norm "$RECOVERYCMD\n";
     }
  } else {
     #delete file is CPU is not high anymore
     $filename = $FILENAME_HIGH;
     unlink $filename or warn "Could not unlink $filename: $!";
  }

  #check to see if file needs to be rolled over
  $size = -s $FILENAME_NORM;
  if ($DEBUG) { print "filesize = $size\n"; }
  if ($size > $MAXSIZE) {
    system("cp -f '$FILENAME_NORM' '$FILENAME_NORM.bak'");
    system("echo > '$FILENAME_NORM'");
  }
}