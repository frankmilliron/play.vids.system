#!/usr/bin/env perl

use strict;
use warnings;

sub rol8($) {
  my ($b) = @_;
  $b = (($b << 1) & 0xFE) | (($b >> 7) & 0x01);
  return $b;
}

for (my $r = 0; $r < 4; ++$r) {
  for (my $c = 0; $c < 16; ++$c) {
    my $b = ($c) | ($c << 4);

    my $b0 = $b & 0x7F; $b = rol8($b);
    my $b1 = $b & 0x7F; $b = rol8($b);
    my $b2 = $b & 0x7F; $b = rol8($b);
    my $b3 = $b & 0x7F; $b = rol8($b);

    for (my $i = 0; $i < 8192; $i += 2) {
      printf("%c%c", $b0, $b2);
    }
    for (my $i = 0; $i < 8192; $i += 2) {
      printf("%c%c", $b1, $b3);
    }
  }
}
