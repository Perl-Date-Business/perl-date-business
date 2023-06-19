#!/usr/bin/perl -w

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

use strict;
use Test::More;
use Date::Business;

my $loaded;

plan tests => 1;

my $d = Date::Business->new();

ok( $d, "Module Loaded" );

