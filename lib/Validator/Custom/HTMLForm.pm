package Validator::Custom::HTMLForm;

our $VERSION = '0.0612';

use warnings;
use strict;

use base 'Validator::Custom';

sub import {
    warn qq{"WARNING: Validator::Custom::HTMLForm" is DEPRECATED!};
}

use Validator::Custom::HTMLForm::Constraints;

sub new {
    my $self = shift->SUPER::new(@_);
    $self->register_constraint(
        email             => \&Validator::Custom::HTMLForm::Constraints::email,
        email_mx          => \&Validator::Custom::HTMLForm::Constraints::email_mx,
        email_loose       => \&Validator::Custom::HTMLForm::Constraints::email_loose,
        email_loose_mx    => \&Validator::Custom::HTMLForm::Constraints::email_loose_mx,
        date              => \&Validator::Custom::HTMLForm::Constraints::date,
        time              => \&Validator::Custom::HTMLForm::Constraints::time,
        datetime          => \&Validator::Custom::HTMLForm::Constraints::datetime,
        datetime_format   => \&Validator::Custom::HTMLForm::Constraints::datetime_format,
        datetime_strptime => \&Validator::Custom::HTMLForm::Constraints::datetime_strptime,
    );
    return $self;
}

1;

=head1 NAME

Validator::Custom::HTMLForm - DEPRECATED!

