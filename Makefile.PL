use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Validator::Custom::HTMLForm',
    AUTHOR              => 'Yuki Kimoto <kimoto.yuki@gmail.com>',
    VERSION_FROM        => 'lib/Validator/Custom/HTMLForm.pm',
    ABSTRACT_FROM       => 'lib/Validator/Custom/HTMLForm.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Validator::Custom' => 0.1208,
        'Date::Calc' => 5.4,
        'Email::Valid' => 0.15,
        'Email::Valid::Loose' => 0.04,
        'Time::Piece' => 1.15,
        'DateTime::Format::Strptime' => 1.07
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Validator-Custom-HTMLForm-*' },
);
