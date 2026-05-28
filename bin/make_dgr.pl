#!/usr/bin/env perl

use strict;
use warnings;

sub ror4($) {
  my ($b) = @_;
  $b = ($b >> 1) | (($b & 1) << 3);
  return $b;
}

for (my $r = 0; $r < 32; ++$r) {
  for (my $c = 0; $c < 16; ++$c) {
    my $main = $c | ($c << 4);
    my $aux = ror4($c) | (ror4($c) << 4);;
    # aux
    for (my $i = 0; $i < 1024; ++$i) {
      printf("%c", $aux);
    }
    # main
    for (my $i = 0; $i < 1024; ++$i) {
      printf("%c", $main);
    }
  }
}
