#!perl
use Test::More tests => 10;
BEGIN
{
    use_ok("DateTime::Util::Calc", qw(mod amod));
}

is( mod( 10, 2 ), 0 );
is( mod( 11, 2 ), 1 );
is( mod( 10, 4 ), 2 );
is( amod( 10, 2 ), 2 );
is( amod( 11, 2 ), 1 );
is( amod( 10, 4 ), 2 );

is( sprintf( '%0.3f', mod( 10.123, 2)), 0.123 );
is( mod( -10, 2 ), 0 );
is( mod( -11, 2 ), 1 );
