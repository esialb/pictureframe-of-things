#!/usr/bin/perl

use File::Basename;

chdir(dirname(__FILE__));

open(SELF, __FILE__) or die "self";
flock(SELF, 2) or die "flock";

my @blines = ();

open(BUFFER, "buffer.txt") or die "read buffer";
while(<BUFFER>) {
  last if(scalar(@blines) == 20);
  push(@blines, $_);
}
close(BUFFER);

my @ilines = ();
while(<>) {
  last if(scalar(@ilines) == 20);
  push(@ilines, $_);
}

my $flash = 0;

my @lines = ();
if(scalar(@ilines) > 1 || length($ilines[0]) > 0) {
  $flash = 1;
  push(@lines, @ilines);
}

push(@lines, @blines);
pop(@lines) while(scalar(@lines) > 20);

my @screen = ();
foreach my $line (@lines) {
  $line =~ s/[^ -~]//g;
  $line = (" " x 32) if(length($line) == 0);
  foreach my $row ($line =~ /.{1,32}/g) {
    $row .= (" " x (32 - length $row));
    push(@screen, $row) if(scalar(@screen) < 20);
  }
}

push(@screen, " " x 32) while(scalar(@screen) < 20);

open(BUFFER, ">buffer.txt") or die "write buffer";
print(BUFFER map {"$_\n"} @screen);
close(BUFFER);

#print("+" . ("-" x 32) . "+\n");
#print(map { /(.{32})/; "|$1|\n"} @screen);
#print("+" . ("-" x 32) . "+\n");

if($flash) {
  open(EPAPER, "| /opt/epaper/epaper /dev/ttyUSB0");
  print(EPAPER join("\n", @screen));
  close(EPAPER);
}
