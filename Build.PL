use strict;
use Module::Build;

my %requires = (
    'DateTime' => 0,
    'Params::Validate' => 0,
    'Math::Trig' => 0,
    'Math::Round' => 0,
    'Math::BigInt' => 0,
    'Math::BigFloat' => 0,
    'POSIX' => 0,
);

my $do_gmp  = 0;
my $do_pari = 0;
my $gmp_installed  = eval { require Math::BigInt::GMP };
my $pari_installed = eval { require Math::BigInt::Pari };

if (!$gmp_installed) {
    $do_gmp = Module::Build->y_n(
      "  Would you like to install Math::BigInt::GMP?\n\n" .
      "  Many astronomical calculations require the arbitrary-precision math\n" .
      "  libraries like GMP. Without it you might see occasional overflows\n" .
      "  which will result in an incorrect calculation.\n" .
      "  To install this you will be required to have installed GMP from\n" .
      "  http://www.swox.com/gmp/ prior to installing this module\n\n" .
      "  Install Math::BigInt::GMP? ",
      "n"
    );
}
    
if ($do_gmp) {
    print "Adding Math::BigInt::GMP to list of prerequisites...\n";
    $requires{ 'Math::BigInt::GMP' } = 0;
}

if (!$pari_installed) {
    $do_pari = Module::Build->y_n(
       "  Would you like to install Math::BigInt::Pari?\n\n" .
       "  Many astronomical calculations require the arbitrary-precision math\n" .
       "  libraries like Pari. Without it you might see occasional overflows\n" .
       "  which will result in an incorrect calculation.\n" .
       "  To install this you will be required to have installed GP/Pari from\n" .
       "  http://www.parigp-home.de/ prior to installing this module\n\n" .
       "  Install Math::BigInt::Pari? ",
       "n"
    );
}

if ($do_pari) {
    print "Adding Math::BigInt::Pari to list of prerequisites...\n";
    $requires{ 'Math::BigInt::Pari' } = 0;
}

if (!$do_gmp && !$do_pari && !$gmp_installed && !$pari_installed) {
    my $proceed = Module::Build->y_n(
        "  ******* WARNING !!! *******\n" .
"  You have chosen not to install either Math::BigInt::GMP or\n" .
"  Math::BigInt::Pari. It is very likely that calculations will overflow,\n" .
"  not necessarily for this module per say, but for others that rely on\n" .
"  this module, such as DateTime::Event::Lunar.\n\n" .
"  Really proceed with installation without installing Math::BigInt::GMP\n" .
"  or Math::BigInt::Pari? ",
        "n"
    );

    if (!$proceed) {
        exit 0;
    }
}


my $build = Module::Build->new(
    module_name => 'DateTime::Util::Calc',
    license => 'perl',
    requires => \%requires,
    build_requires => {
        'Test::More' => 0
    },
    sign => 1,
    create_makefile_pl => 'passthrough'
);
$build->create_build_script;
