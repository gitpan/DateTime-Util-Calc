#!perl
use strict;
use Test::More tests => 7;

BEGIN
{
	use_ok('DateTime::Util::Calc',
		'sin_deg', 'cos_deg', 'tan_deg', 'asin_deg', 'acos_deg', );
	use_ok('Math::Trig',
		'tan', 'asin', 'acos', 'deg2rad');
}

my $a = rand(360);
ok( sin_deg($a) == sin(deg2rad($a)) );
ok( cos_deg($a) == cos(deg2rad($a)) );
ok( tan_deg($a) == tan(deg2rad($a)) );
ok( asin_deg($a) == asin(deg2rad($a)) );
ok( acos_deg($a) == acos(deg2rad($a)) );

