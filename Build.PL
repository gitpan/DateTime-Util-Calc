#!perl
# $Id: Build.PL,v 1.11 2005/01/07 12:14:18 lestrrat Exp $
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

use strict;
use Module::Build;

my $mod_installed  = eval { require DateTime::Util::Calc };
my $limit_ver      = '0.04';
if ($mod_installed && $DateTime::Util::Calc::VERSION < $limit_ver) {
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

my $gmp_installed  = eval { require Math::BigInt::GMP };
my $pari_installed = eval { require Math::BigInt::Pari };

if (!$gmp_installed && !$pari_installed) {
    my $message = <<EOM;

================================================================================
+  You don't seem to have neither Math::BigInt::GMP and Math::BigInt::Pari
+
+  Many astronomical calculations require the arbitrary-precision math
+  libraries like GMP. Without it you might see occasional overflows
+  which will result in an incorrect calculation. It is recommended that
+  you install either one of the module (If both are installed, GMP will
+  be used)
+
+  To install GMP, you will be required to have installed GMP library from
+  http://www.swox.com/gmp/ prior to installing the Perl module
+
+  To install Pari, you will be required to have installed Pari from
+  http://www.parigp-home.de/ prior to installing the Perl module.
+
+  Proceed with installation without Math::BigInt::GMP or Math::BigInt::Pari?
EOM
    chomp $message;
    my $proceed = Module::Build->y_n($message, "n");

    if (!$proceed) {
        print "\nAbort\n";
        exit 0;
    }
}
    
my $class = Module::Build->subclass(code => q|
    sub ACTION_manifest
    {
        my $self = shift;
        $self->SUPER::ACTION_manifest();
        if ($self->create_makefile_pl) {
            $self->_add_to_manifest('MANIFEST', 'Makefile.PL       Added here by Build.PL');
        }
    }
|);

my $build = $class->new(
    module_name => 'DateTime::Util::Calc',
    module_author => 'Daisuke Maki <dmaki@cpan.org>',
    license => 'perl',
    requires => {
        'DateTime' => 0,
        'Math::Trig' => 0,
        'Math::BigInt' => 0,
        'Math::BigFloat' => 0,
    },
    recommends => {
        'Math::BigInt::GMP' => 0
    },
    build_requires => {
        'Test::More' => 0
    },
    sign => 1,
    create_makefile_pl => 'traditional'
);

$build->create_build_script;
