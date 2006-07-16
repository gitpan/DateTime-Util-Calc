#!perl
use strict;
use Test::More tests => 6;

BEGIN
{
	use_ok('DateTime::Util::Calc', 'bigfloat', 'bf_downgrade');
}

my $x  = sprintf('%0.6f', rand());

my $bf = bigfloat($x);
ok( UNIVERSAL::isa($bf, 'Math::BigFloat') );

my $downgraded = bf_downgrade($bf);
ok( !ref($downgraded) );

# for some reason "eq" here works, but not "=="
$downgraded = sprintf('%0.6f', $downgraded);
ok( ($downgraded + 0) eq $x, "$downgraded == $x" );

$bf = bigfloat($x);
ok( ref($bf) );

ok( bf_downgrade($x) == $x );
