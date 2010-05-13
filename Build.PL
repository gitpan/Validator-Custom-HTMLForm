use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Validator::Custom::HTMLForm',
    license             => 'perl',
    dist_author         => 'Yuki Kimoto <kimoto.yuki@gmail.com>',
    dist_version_from   => 'lib/Validator/Custom/HTMLForm.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'Validator::Custom::Trim' => 0.0502,
        'Date::Calc' => 5.4,
        'Email::Valid' => 0.15,
        'Email::Valid::Loose' => 0.04,
        'Time::Piece' => 1.15,
        'DateTime::Format::Strptime' => 1.07
    },
    add_to_cleanup      => [ 'Validator-Custom-HTMLForm-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
