#!/usr/bin/perl

print "Content-type: text/html\n\n";

my $index = "";
open(INDEX, "/www/epaper/index.shtml");
while(<INDEX>) {
  $index .= $_;
}
close(INDEX);

my @lines = ();

open(BUFFER, "/opt/epaper/buffer.txt");
while(<BUFFER>) {
  /(.{32})/;
  my $line = $1;
  $line =~ s/\s+$//;
  push(@lines, $line);
}
close(BUFFER);

my $display = join("\n", @lines);

$display =~ s/(["\&<>])/"&#" . ord($1) . ";"/eg;

$index =~ s/<!-- #include virtual="display.pl" -->/$display/g;

print $index;
