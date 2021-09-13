#!/usr/bin/perl
use warnings;
use List::MoreUtils qw(uniq);
use Data::Dumper qw(Dumper);


my $filename = '/Users/mwiles/Desktop/log-insight-event-results-There is no more space for virtual disk.csv';

open(FH, '<', $filename) or die $!;
@yourarray;

while(<FH>){
   #*Message on veeambs01-tRbx on*
   #print $_;

   if ($_ =~ /Message on/) {
       @stuff = split /Message on /, $_;
       
       @stuffs = split / on /, $stuff[1];
       #print $stuffs[0] . "\n";

       push(@yourarray, $stuffs[0]);
   }

}

close(FH);

my @unique_words = uniq @yourarray;
print  Dumper \@unique_words;