#!/usr/bin/perl

use CGI;

my $q = CGI->new;

die unless (open PIPE, "| /opt/epaper/write.pl");
print(PIPE $q->param('t')) if($q->param('t'));
close PIPE;

print "Location: /\n\n";
