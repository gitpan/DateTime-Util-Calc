#!perl
use strict;
use Test::More tests => 5;

BEGIN
{
	use_ok('DateTime::Util::Calc', 'moment', 'dt_from_moment');
	use_ok('DateTime');
}

my $dt = DateTime->now();

my $moment = moment($dt);
ok($moment && !ref($moment));

my $dt_from_moment = dt_from_moment($moment);
ok(UNIVERSAL::isa($dt_from_moment, 'DateTime'));

ok( DateTime->compare($dt, $dt_from_moment) == 0);


