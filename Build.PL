use strict;
use Module::Build;

my $build = Module::Build->new(
	module_name => 'DateTime::Util::Calc',
	license => 'perl',
	requires => {
		'DateTime' => 0,
		'Params::Validate' => 0,
		'Math::Trig' => 0,
		'Math::Round' => 0,
		'POSIX' => 0,
	},
	recommends => {
		'perl' => '5.6.1',
		'Math::BigInt' => 0,
		'Math::BigFloat' => 0,
		'Math::BigInt::GMP' => 0,
	},
	build_requires => {
		'Test::More' => 0
	},
	sign => 1,
	create_readme => 1
);
$build->create_build_script;
