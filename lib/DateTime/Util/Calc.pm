# $Id: Calc.pm,v 1.15 2005/01/07 12:31:50 lestrrat Exp $
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

package DateTime::Util::Calc;
use strict;
use DateTime;
use Math::BigInt   ('upgrade' => 'Math::BigFloat');
use Math::BigFloat ('lib' => 'GMP,Pari');
use Math::Trig ();
use POSIX();

use constant RATA_DIE => DateTime->new(year => 1, time_zone => 'UTC');

use vars qw($VERSION @EXPORT_OK @ISA);
use vars qw($DOWNGRADE_ACCURACY);
BEGIN
{
    $VERSION = '0.08';
    @ISA = qw(Exporter);
    @EXPORT_OK = qw(
        binary_search
        search_next
        angle
        bf_downgrade
        polynomial
        sin_deg
        cos_deg
        tan_deg
        asin_deg acos_deg mod amod min
        max bigfloat bigint moment dt_from_moment rata_die
        truncate_to_midday
        revolution
        rev180
    );

    $DOWNGRADE_ACCURACY = 32;
}

sub rata_die { RATA_DIE->clone }

sub bigfloat
{
    return
        UNIVERSAL::isa($_[0], 'Math::BigFloat') ? $_[0] :
            Math::BigFloat->new($_[0]);
}

sub bigint
{
    return UNIVERSAL::isa($_[0], 'Math::BigInt') ? $_[0] : Math::BigInt->new($_[0]);
}

# Downgrades to float
sub bf_downgrade
{
    return UNIVERSAL::isa($_[0], 'Math::BigInt') ? 
        $_[0]->bround($_[1] || $DOWNGRADE_ACCURACY)->bstr() : $_[0];
}

sub bi_downgrade
{
    return UNIVERSAL::isa($_[0], 'Math::BigInt') ? 
        $_[0]->as_int()->bstr() : $_[0];
}

sub angle
{
    $_[0] + ($_[1] + ($_[2] / 60)) / 60;
}

# polynomial($x, $a(0) ... $a(n))
sub polynomial
{
    if (@_ == 1) {
        require Carp;
        Carp::croak('polynomial requires at least two arguments: polynomial($x, @coeffients)');
    }

    # XXX - There seems to be a bug in adding BigInt and BigFloat
    # Math::BigFloat->bzero must be used
    my $x   = bigfloat(shift @_);
    my $v   = Math::BigFloat->bzero();
    my $ret = bigfloat(shift @_);

    # reuse $v for sake of efficiency. we just want to check if $x
    # is zero or not
    if ($x == $v) {
        return $ret;
    }

    while (@_) {
        $v = $x * ($v + pop @_);
    }
    return $ret + $v;
}

sub deg2rad
{
    my $deg = bi_downgrade($_[0]);
    return Math::Trig::deg2rad($deg > 360 ? $deg % 360 : $deg);
}

sub sin_deg  { CORE::sin(deg2rad($_[0])) }
sub cos_deg  { CORE::cos(deg2rad($_[0])) }
sub tan_deg  { Math::Trig::tan(deg2rad($_[0])) }
sub asin_deg { Math::Trig::rad2deg(Math::Trig::asin(bf_downgrade($_[0]))) }
sub acos_deg { Math::Trig::rad2deg(Math::Trig::acos(bf_downgrade($_[0]))) }

sub mod
{
    my $num = bigint(shift);
    my $mod = shift;

    return $num->bmod($mod);
}

sub amod
{
    my($num, $mod) = @_;
    return mod($num, $mod) || $mod;
}

sub min { $_[0] > $_[1] ? $_[1] : $_[0] }
sub max { $_[0] < $_[1] ? $_[1] : $_[0] }

# always return UTC rd moments
sub moment
{
    my $dt = shift;
    $dt = $dt->clone;
    $dt->set_time_zone('UTC');
    my($rd, $seconds) = $dt->utc_rd_values;
    return $rd + $seconds / (24 * 3600);
}

sub dt_from_moment
{
    my $moment  = bf_downgrade(shift);
    my $rd_days = int($moment);

    # Upgrade here to BigFloat to maintain accuracy to the second
    my $time    = bigfloat($moment - $rd_days) * 24 * 3600;
    my $dt      = rata_die();

    if ($rd_days || $time) {
        $dt->add(
            days    => bf_downgrade($rd_days - 1),
            seconds => bi_downgrade($time));
        $dt->truncate(to => 'second');
    }
    return $dt;
}

    
sub binary_search
{
    my ($lo, $hi, $mu, $phi) = @_;
    while (1) {
        my $x = ($lo + $hi) / 2;
        if ($mu->($lo, $hi)) {
            return $x;
        } elsif ($phi->($x)) {
            $hi = $x;
        } else {
            $lo = $x;
        }
    }
}

sub __increment_one { $_[0] + 1 }
sub search_next
{
    my %args = @_;
    my $x     = $args{base};
    my $check = $args{check};
    my $next  = $args{next} || \&__increment_one;
    while (! $check->($x) ) {
        $x = $next->($x);
    }
    return $x;
}

sub truncate_to_midday
{
    $_[0]->set( hour => 12 );
    $_[0]->set( minute => 0 );
    $_[0]->set( second => 0 );

    $_[0];
}

sub revolution
{
    #
    #
    # FUNCTIONAL SEQUENCE for revolution
    #
    # _GIVEN
    # any angle
    #
    # _THEN
    #
    # reduces any angle to within the first revolution 
    # by subtracting or adding even multiples of 360.0
    # 
    #
    # _RETURN
    #
    # the value of the input is >= 0.0 and < 360.0
    #

    my $x = $_[0];
    return ( $x - 360.0 * floor( $x * ( 1.0 / 360.0 ) ) );
}

sub rev180
{
    #
    #
    # FUNCTIONAL SEQUENCE for rev180
    #
    # _GIVEN
    # 
    # any angle
    #
    # _THEN
    #
    # Reduce input to within +180..+180 degrees
    # 
    #
    # _RETURN
    #
    # angle that was reduced
    #
    my ($x) = @_;
    return ( $x - 360.0 * floor( $x * ( 1.0 / 360.0 ) + 0.5 ) );
}


1;

__END__

=head1 NAME

DateTime::Util::Calc - Calculation Utilities

=head1 SYNOPSIS

  use DateTime::Util::Calc qw(polynomial);

  my @coeffs = qw(2 3 -2);
  my $x      = 5;
  my $rv     = polynomial($x, @coeffs);

=head1 DESCRIPTION

This module contains some common calculation utilities that are required
to perform datetime calculations, specifically from "Calendrical Calculations"
-- they are NOT meant to be general purpose.

Nothing is exported by default. You must either explicitly export them,
or use as fully qualified function names.

=head1 FUNCTIONS

=head2 polynomial($x, @coefs)

Calculates the value of a polynomial equation, based on Horner's Rule.

   c + b * x + a * (x ** 2)     x = 5

is expressed as:

   polynomial(5, c, b, a);

=head2 bf_downgrade($v)

If the value $v is a Math::BigFloat object, returns the "downgraded", 
regular Perl scalar version of $v. This is sometimes required for functions
or objects that do not accept Math::BigFloat.

If $v is not Math::BigFloat object, just returns the value itself.

=head2 sin_deg($degrees)

=head2 cos_deg($degrees)

=head2 tan_deg($degrees)

=head2 asin_deg($degrees)

=head2 acos_deg($degrees)

Each of these functions calculates their respective values based on degrees,
not radians (as Perl's version of sin() and cos() would do).

Since Math::BigFloat does not have corresponding trigonemetric functions,
values passed to these funtions will be automatically downgraded via
bf_downgrade()

=head2 mod($v,$mod)

Calculates the modulus of $v over $mod. Perl's built-in modulus operator (%)
for some reason rounds numbers UP when a fractional number's modulus is
taken. Many of the calculations also needed the fractional part of the
calculation, so this function takes care of both.

Example:

  mod(12.234, 5) = 2.234

=head2 amod($v,$mod)

This function is almost identical to mod(), but when the regular modulus value
is 0, returns $mod instead of 0.

Example:

  amod(11, 5) = 1
  amod(10, 5) = 5
  amod(9, 5)  = 4
  amod(8, 5)  = 3

=head2 search_next(%opts)

Performs a "linear" search until some condition is met. This is a generalized
version of the formula defined in [1] p.22. The basic idea is :

  x = base
  while (! check(x) ) {
     x = next(x);
  }
  return x

%opts can contain the following parameters:

=over 4

=item base

The initial value to use to start the search process. The value can be
anything, but you must provide C<check> and C<next> parameters that are
capable of handling the type of thing you specified.

=item check (coderef)

Code to be executed to determine the end of the search. The function receives
the current value of "x", and should return a true value if the condition
to end the loop has been reached

=item next (coderef, optional)

Code to be executed to determine the next value of "x". The function receives
the current value of "x", and should return the value to be used for the
next iteration.

If unspecified, it will use a function that blindly adds 1 to whatever x is.
(so if you specified a number for C<base>, it should work -- but if you
passed an object like DateTime, it will probably be an error)

=back

So for example, to iterate through 1 through 9, you could do something
like this

  my $x = search_next(
    base => 1,
    check => sub { $_[0] == 9 }
  );

And $x will be set to 9. For a more interesting example, we could look
for a DateTime object $dt matching a certain condition C<foo()>:

  my $dt = search_next(
    base  => $base_date,
    check => \&foo,
    next  => sub { $_[0] + DateTime::Duration->new(days => 1) }
  );

=head2 revolution($angle_in_degrees)

Reduces any angle to within the first revolution by sbtracting or adding
even multiples of 360.0.

=head2 rev180($angle_in_degrees)

Reduces input to within +180..+180 degrees

=head1 CAVEATS

For performance reasons, there is absolutely no parameter validation via
Params::Validate in this module!

=head1 AUTHOR

Daisuke Maki E<lt>daisuke@cpan.orgE<gt>

=cut

