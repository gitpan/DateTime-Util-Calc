#!perl
use strict;
use Test::More tests => 7;

BEGIN { use_ok('DateTime::Util::Calc', 'min', 'max') }


ok(min(-2, 0) == -2);
ok(max(-2, 0) == 0);
ok(min(23,23) == 23);
ok(max(23,23) == 23);
ok(min(0, 10) == 0);
ok(max(0, 10) == 10);
