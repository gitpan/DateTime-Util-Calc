#!perl
# $Id: Build.PL,v 1.6 2005/01/06 13:35:28 lestrrat Exp $
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

use strict;
use CPAN;
use Module::Build;

my $mod       = CPAN::Shell->expand("Module", "DateTime::Util::Calc");
my $limit_ver = '0.04';
if ($mod && $mod->inst_version < $limit_ver) {
    my $message = <<EOM;

================================================================================
+  You seem to have DateTime::Util::Calc version < 0.04, which did not
+  necessarily required you to use Math::BigInt / Math::BigFloat et al.
+  From version $limit_ver on, the use of Math::BigInt / Math::BigFloat
+  is required. 

+  This was the recommended usage anyway, but this time it's mandatory.
+  If for some reason you have a problem with this, you probably shouldn't
+  upgrade this module.

+  Upgrade DateTime::Util::Calc?
EOM

    chomp $message;
    my $do_upgrade = Module::Build->y_n($message, "y");
    if (!$do_upgrade) {
        print "\nAbort\n";
        exit 0;
    }
}

my %requires = (
    'DateTime' => 0,
    'Math::Trig' => 0,
    'Math::BigInt' => 0,
    'Math::BigFloat' => 0,
);

my $do_gmp  = 0;
my $do_pari = 0;
my $gmp_installed  = do {
    my $mod = CPAN::Shell->expand("Module", "Math::BigInt::GMP");
    $mod->inst_version();
};
my $pari_installed = do {
    my $mod = CPAN::Shell->expand("Module", "Math::BigInt::Pari");
    $mod->inst_version();
};

if (!$gmp_installed) {
    my $message = <<EOM;

================================================================================
+  Would you like to install Math::BigInt::GMP?
+
+  Many astronomical calculations require the arbitrary-precision math
+  libraries like GMP. Without it you might see occasional overflows
+  which will result in an incorrect calculation.
+
+  To install this you will be required to have installed GMP from
+  http://www.swox.com/gmp/ prior to installing this module
+
+  Install Math::BigInt::GMP?
EOM
    chomp $message;
    $do_gmp = Module::Build->y_n($message, "n");
}
    
if ($do_gmp) {
    print "Adding Math::BigInt::GMP to list of prerequisites...\n";
    $requires{ 'Math::BigInt::GMP' } = 0;
}

if (!$pari_installed) {
    my $message = <<EOM;

================================================================================
+  Would you like to install Math::BigInt::Pari?
+
+  Many astronomical calculations require the arbitrary-precision math
+  libraries like Pari. Without it you might see occasional overflows
+  which will result in an incorrect calculation.
+
+  To install this you will be required to have installed GP/Pari from
+  http://www.parigp-home.de/ prior to installing this module
+
+  Install Math::BigInt::Pari?
EOM
    chomp $message;
    $do_pari = Module::Build->y_n($message, "n");
}

if ($do_pari) {
    print "Adding Math::BigInt::Pari to list of prerequisites...\n";
    $requires{ 'Math::BigInt::Pari' } = 0;
}

if (!$do_gmp && !$do_pari && !$gmp_installed && !$pari_installed) {
    my $message = <<EOM;

******************************** WARNING !!! ***********************************
+  You have chosen not to install either Math::BigInt::GMP or
+  Math::BigInt::Pari. It is very likely that calculations will overflow,
+  not necessarily for this module per say, but for others that rely on
+  this module, such as DateTime::Event::Lunar.
+
+  Really proceed with installation without installing Math::BigInt::GMP
+  or Math::BigInt::Pari?
EOM
    chomp $message;
    my $proceed = Module::Build->y_n($message, "n");

    if (!$proceed) {
        print "\nAbort\n";
        exit 0;
    }
}

my $build = Module::Build->new(
    module_name => 'DateTime::Util::Calc',
    module_author => 'Daisuke Maki <dmaki@cpan.org>',
    license => 'perl',
    requires => \%requires,
    build_requires => {
        'Test::More' => 0
    },
    sign => 1,
    create_makefile_pl => 'traditional'
);

$build->create_build_script;
