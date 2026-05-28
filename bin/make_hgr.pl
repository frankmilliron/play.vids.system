#!/usr/bin/env perl

use strict;
use warnings;

my @patterns = (
  0x00,
  0x55,
  0xAA,
  0x55,
  0xAA,
  0xFF,
    );
my @flags = (
  0x00,
  0x00,
  0x00,
  0x80,
  0x80,
  0x00,
    );

sub ror8($) {
  my ($b) = @_;
  $b = ($b >> 1) | (($b << 7) & 0x80);
  return $b;
}

for (my $r = 0; $r < 22; ++$r) {
  for (my $c = 0; $c < 6; ++$c) {
    my $even = ($patterns[$c] & 0x7F) | $flags[$c];
    my $odd  = (ror8($patterns[$c]) & 0x7F) | $flags[$c];
    for (my $i = 0; $i < 8192; $i += 2) {
      printf("%c%c", $even, $odd);
    }
  }
}
