#!/usr/bin/env perl

use strict;
use warnings;

for (my $r = 0; $r < 64; ++$r) {
  for (my $c = 0; $c < 16; ++$c) {
    my $main = $c | ($c << 4);
    for (my $i = 0; $i < 1024; ++$i) {
      printf("%c", $main);
    }
  }
}
