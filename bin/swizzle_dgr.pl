#!/usr/bin/env perl

use strict;
use warnings;

$/ = 1;

for (;;) {
  my $main;
  my $aux;

  read(STDIN, $main, 0x400) or exit();
  read(STDIN, $aux,  0x400) or exit();

  print $aux;
  print $main;
}

