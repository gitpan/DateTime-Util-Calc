#!perl
use strict;
use Test::More tests => 7;

BEGIN
{
	use_ok('DateTime::Util::Calc', 'bigfloat', 'bf_downgrade');
}

my $x  = sprintf('%0.6f', rand());

SKIP: {
	skip("BigFloat not enabled", 5)
		if $DateTime::Util::Calc::NoBigFloat;
	my $bf = bigfloat($x);
	ok( UNIVERSAL::isa($bf, 'Math::BigFloat') );

	my $downgraded = bf_downgrade($bf);
	ok( !ref($downgraded) );

	# for some reason "eq" here works, but not "=="
	ok( ($downgraded + 0) eq $x, "$downgraded == $x" );

	local $DateTime::Util::Calc::NoBigFloat = 1;

	$bf = bigfloat($x);
	ok( ref($bf) );
	ok( $bf == $x );
}

ok( bf_downgrade($x) == $x );
