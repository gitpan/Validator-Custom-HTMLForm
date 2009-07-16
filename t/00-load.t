#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Validator::Custom::HTMLForm' );
}

diag( "Testing Validator::Custom::HTMLForm $Validator::Custom::HTMLForm::VERSION, Perl $], $^X" );
