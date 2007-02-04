#!perl
use strict;
use inc::Module::Install;

name("DateTime-Util-Calc");
license("perl");
perl_version("5.6.1");
all_from("lib/DateTime/Util/Calc.pm");

requires "DateTime";
requires "Math::BigInt";
requires "Math::BigFloat";
requires "Math::Trig";
build_requires("Test::More");

features(
    'Fast BigInt Support (FastCalc)' => [
        -default => 0,
        recommends('Math::BigInt::FastCalc')
    ],
    'Fast BigInt Support (GMP)' => [
        -default => 0,
        recommends('Math::BigInt::GMP')
    ],
    'Fast BigInt Support (Pari)' => [
        -default => 0,
        recommends('Math::BigInt::Pari')
    ],
);

auto_install;
WriteAll;

1;
