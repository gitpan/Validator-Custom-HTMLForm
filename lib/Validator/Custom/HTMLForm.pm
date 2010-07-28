package Validator::Custom::HTMLForm;

use warnings;
use strict;

use base 'Validator::Custom';

use Validator::Custom::Trim;
use Validator::Custom::HTMLForm::Constraints;

__PACKAGE__->register_constraint(
    %{Validator::Custom::Trim->constraints},
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

1;

=head1 NAME

Validator::Custom::HTMLForm - HTML Form Validator

=cut

our $VERSION = '0.0608';

=head1 SYNOPSIS

    use Validator::Custom::HTMLForm;
    
    # Data
    my $data = {
        name => 'ABCD',
        age =>  29,

        mail1  => 'name@gmail.com',
        mail2  => 'name@gmail.com',

        year   => 2005,
        month  =>   11,
        day    =>   27,
    }
    
    # Validation rule
    my $rule = [
        name => [
            'not_blank',
            'ascii',
            {length => [1, 30]}
        ],
        age => [
            'not_blank',
            'int'
        ],
        
        mail1  => [
            'trim',
            'not_blank',
            'email_loose'
        ],
        mail2  => [
            'not_blank',
            'email_loose'
        ],
        
        [qw/mail1 mail2/] => [
            'duplication'
        ],
        
        { date  => ['year',  'month', 'day'] } => [
            'date'
        ]
    ]
    
    # Create validator object
    my $vc = Validator::Custom::HTMLForm->new;
    
    # Validate
    my $result = $vc->validate($data, $rule);

=head1 DESCRIPTION

L<Validator::Custom::HTMLForm> is HTML form validator.
This class inherit all methods from L<Validator::Custom>.
If you know usage of This module, See L<Validator::Custom>
documentation.

=head1 METHODS

This module is L<Validator::Custom> subclass.
All methods of L<Validator::Custom> is available.

=head1 CONSTRAINT FUNCTIONS

L<Validator::Custom::HTMLForm> inherit all constraints from 
L<Validator::Custom> and L<Validator::Custom::Trim>.

=head2 C<email>

Check with L<Email::Valid>.

    my $data = {mail => 'a@somehost.com'};
    my $rule => [
        mail => [
            'email'
        ]
    ];

=head2 C<email_mx>

check with L<Email::Valid>, including  mx check.

    my $data = {mail => 'a@somehost.com'};
    my $rule => [
        mail => [
            'email_mx'
        ]
    ];

=head2 C<email_loose>

check with L<Email::Valid::Loose>.

    my $data = {mail => 'a.@somehost.com'};
    my $rule => [
        mail => [
            'email_loose'
        ]
    ];

=head2 C<email_loose_mx>

    my $data = {mail => 'a.@somehost.com'};
    my $rule => [
        mail => [
            'email_loose'
        ]
    ];

=head2 C<date>

check with L<Date::Calc>

    my $data = {year => '2009', month => '12', day => '13'};
    my $rule => [
        {date => [qw/year month day/]} => [
            'date'
        ]
    ];
    
    $result->data->{date}; # 2009-12-13 00:00:00

You can specify options

    # Convert DateTime object
    my $rule => [
        {date => [qw/year month day/]} => [
            {'date' => {'datetime_class' => 'DateTime', time_zone => 'Asia/Tokyo'}}
        ]
    ];
    
    $result->data->{date}; # DateTime object


    # Convert Time::Piece object
    my $rule => [
        {date => [qw/year month day/]} => [
            {'date' => {'datetime_class' => 'Time::Piece'}}
        ]
    ];
    
    $result->data->{date}; # Time::Piece object

=head2 C<time>

check with L<Date::Calc>

    my $data = {hour => '12', minute => '40', second => '13'};
    my $rule => [
        [qw/hour minute second/] => [
            'time'
        ]
    ];

=head2 C<datetime>

check with L<Date::Calc>

    my $data = {
        year => '2009', month => '12',  day => '13'
        hour => '12',   minute => '40', second => '13'
    };
    my $rule => [
        {datetime => [qw/year month day hour minute second/]} => [
            'datetime'
        ]
    ];
    
    $result->data->{datetime}; # 2009-12-13 12:40:13

You can specify options

    # Convert DateTime object
    my $rule => [
        {datetime => [qw/year month day hour minute second/]} => [
            {'datetime' => {'datetime_class' => 'DateTime', time_zone => 'Asia/Tokyo'}}
        ]
    ];
    
    $result->data->{date}; # DateTime object


    # Convert Time::Piece object
    my $rule => [
        {datetime => [qw/year month day hour minute second/]} => [
            {'datetime' => {'datetime_class' => 'Time::Piece'}}
        ]
    ];
    
    $result->data->{date}; # Time::Piece object

=head2 C<datetime_strptime>

check with L<DateTime::Format::Strptime>.

    my $data = {datetime => '2006-04-26T19:09:21+0900'};

    my $rule => [
        datetime => [
            {'datetime_strptime' => '%Y-%m-%dT%T%z'}
        ]
    ];
    
    $result->data->{datetime}; # DateTime object

=head2 C<datetime_format>

check with DateTime::Format::***. for example, L<DateTime::Format::HTTP>,
L<DateTime::Format::Mail>, L<DateTime::Format::MySQL> and etc.

    my $data = {datetime => '2004-04-26 19:09:21'};

    my $rule = [
        datetime => [
            {datetime_format => 'MySQL'}
        ]
    ];

=head2 C<in_array>

check if the food ordered is in menu

    my $rule = [
        food => [
            {in_array => [qw/sushi bread apple/]}
        ]
    ];

=head2 STABILITY

L<Validator::Custom::HTMLForm> is stable.
All constraints keep backword compatible.

=head1 AUTHOR

Yuki Kimoto, C<< <kimoto.yuki at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Yuki Kimoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

