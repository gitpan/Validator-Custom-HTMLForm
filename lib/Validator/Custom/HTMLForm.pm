package Validator::Custom::HTMLForm;

use warnings;
use strict;

use base 'Validator::Custom';

use Validator::Custom::Trim;
use Validator::Custom::HTMLForm::Constraints;

__PACKAGE__->register_constraint(
    %{Validator::Custom::Trim->constraints},
    not_defined       => \&Validator::Custom::HTMLForm::Constraints::not_defined,
    defined           => \&Validator::Custom::HTMLForm::Constraints::defined,
    not_space         => \&Validator::Custom::HTMLForm::Constraints::not_space,
    not_blank         => \&Validator::Custom::HTMLForm::Constraints::not_blank,
    blank             => \&Validator::Custom::HTMLForm::Constraints::blank,
    int               => \&Validator::Custom::HTMLForm::Constraints::int,
    uint              => \&Validator::Custom::HTMLForm::Constraints::uint,
    ascii             => \&Validator::Custom::HTMLForm::Constraints::ascii,
    duplication       => \&Validator::Custom::HTMLForm::Constraints::duplication,
    length            => \&Validator::Custom::HTMLForm::Constraints::length,
    regex             => \&Validator::Custom::HTMLForm::Constraints::regex,
    email             => \&Validator::Custom::HTMLForm::Constraints::email,
    email_mx          => \&Validator::Custom::HTMLForm::Constraints::email_mx,
    email_loose       => \&Validator::Custom::HTMLForm::Constraints::email_loose,
    email_loose_mx    => \&Validator::Custom::HTMLForm::Constraints::email_loose_mx,
    date              => \&Validator::Custom::HTMLForm::Constraints::date,
    time              => \&Validator::Custom::HTMLForm::Constraints::time,
    datetime          => \&Validator::Custom::HTMLForm::Constraints::datetime,
    http_url          => \&Validator::Custom::HTMLForm::Constraints::http_url,
    selected_at_least => \&Validator::Custom::HTMLForm::Constraints::selected_at_least,
    greater_than      => \&Validator::Custom::HTMLForm::Constraints::greater_than,
    less_than         => \&Validator::Custom::HTMLForm::Constraints::less_than,
    equal_to          => \&Validator::Custom::HTMLForm::Constraints::equal_to,
    between           => \&Validator::Custom::HTMLForm::Constraints::between,
    decimal           => \&Validator::Custom::HTMLForm::Constraints::decimal,
    in_array          => \&Validator::Custom::HTMLForm::Constraints::in_array,
    datetime_format   => \&Validator::Custom::HTMLForm::Constraints::datetime_format,
    datetime_strptime => \&Validator::Custom::HTMLForm::Constraints::datetime_strptime,
);

1;

=head1 NAME

Validator::Custom::HTMLForm - HTML Form Validator

=head1 VERSION

Version 0.0606

=cut

our $VERSION = '0.0606';

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

L<Validator::Custom::HTMLForm> inherit all constraints from L<Validator::Custom::Trim>.
and implemenents the following new ones.

=head2 defined

check if the data is defined.

=head2 not_defined

check if the data is not defined.

=head2 not_blank

check if the data is not blank.

=head2 blank

check if the is blank.

=head2 not_space

check if the data do not containe space.

=head2 int

check if the data is integer.
    
    # valid data
    123
    -134

=head2 uint

check if the data is unsigned integer.

    # valid data
    123
    
=head2 decimal
    
    my $data = { num => '123.45678' };
    my $rule => [
        num => [
            {'decimal' => [3, 5]}
        ]
    ];

    Validator::Custom::HTMLForm->new->validate($data,$rule);

each numbers (3,5) mean maximum digits before/after '.'

=head2 ascii

check is the data consists of only ascii code.

=head2 length

check the length of the data.

The following sample check if the length of the data is 4 or not.

    my $data = { str => 'aaaa' };
    my $rule => [
        num => [
            {'length' => 4}
        ]
    ];

when you set two arguments, it checks if the length of data is in
the range between 4 and 10.
    
    my $data = { str => 'aaaa' };
    my $rule => [
        num => [
            {'length' => [4, 10]}
        ]
    ];

=head2 http_url

verify it is a http(s)-url

    my $data = { url => 'http://somehost.com' };
    my $rule => [
        url => [
            'http_url'
        ]
    ];

=head2 selected_at_least

verify the quantity of selected parameters is counted over allowed minimum.

    <input type="checkbox" name="hobby" value="music" /> Music
    <input type="checkbox" name="hobby" value="movie" /> Movie
    <input type="checkbox" name="hobby" value="game"  /> Game
    
    
    my $data = {hobby => ['music', 'movie' ]};
    my $rule => [
        hobby => [
            {selected_at_least => 1}
        ]
    ];

=head2 regex

check with regular expression.
    
    my $data = {str => 'aaa'};
    my $rule => [
        str => [
            {regex => qr/a{3}/}
        ]
    ];

=head2 duplication

check if the two data are same or not.

    my $data = {mail1 => 'a@somehost.com', mail2 => 'a@somehost.com'};
    my $rule => [
        [qw/mail1 mail2/] => [
            'duplication'
        ]
    ];

=head2 email

check with L<Email::Valid>.

    my $data = {mail => 'a@somehost.com'};
    my $rule => [
        mail => [
            'email'
        ]
    ];

=head2 email_mx

check with L<Email::Valid>, including  mx check.

    my $data = {mail => 'a@somehost.com'};
    my $rule => [
        mail => [
            'email_mx'
        ]
    ];

=head2 email_loose

check with L<Email::Valid::Loose>.

    my $data = {mail => 'a.@somehost.com'};
    my $rule => [
        mail => [
            'email_loose'
        ]
    ];

=head2 email_loose_mx

    my $data = {mail => 'a.@somehost.com'};
    my $rule => [
        mail => [
            'email_loose'
        ]
    ];

=head2 date

check with L<Date::Calc>

    my $data = {year => '2009', month => '12', day => '13'};
    my $rule => [
        {date => [qw/year month day/]} => [
            'date'
        ]
    ];
    
    $result->products->{date}; # 2009-12-13 00:00:00

You can specify options

    # Convert DateTime object
    my $rule => [
        {date => [qw/year month day/]} => [
            {'date' => {'datetime_class' => 'DateTime', time_zone => 'Asia/Tokyo'}}
        ]
    ];
    
    $result->products->{date}; # DateTime object


    # Convert Time::Piece object
    my $rule => [
        {date => [qw/year month day/]} => [
            {'date' => {'datetime_class' => 'Time::Piece'}}
        ]
    ];
    
    $result->products->{date}; # Time::Piece object

=head2 time

check with L<Date::Calc>

    my $data = {hour => '12', minute => '40', second => '13'};
    my $rule => [
        [qw/hour minute second/] => [
            'time'
        ]
    ];

=head2 datetime

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
    
    $result->products->{datetime}; # 2009-12-13 12:40:13

You can specify options

    # Convert DateTime object
    my $rule => [
        {datetime => [qw/year month day hour minute second/]} => [
            {'datetime' => {'datetime_class' => 'DateTime', time_zone => 'Asia/Tokyo'}}
        ]
    ];
    
    $result->products->{date}; # DateTime object


    # Convert Time::Piece object
    my $rule => [
        {datetime => [qw/year month day hour minute second/]} => [
            {'datetime' => {'datetime_class' => 'Time::Piece'}}
        ]
    ];
    
    $result->products->{date}; # Time::Piece object

=head2 datetime_strptime

check with L<DateTime::Format::Strptime>.

    my $data = {datetime => '2006-04-26T19:09:21+0900'};

    my $rule => [
        datetime => [
            {'datetime_strptime' => '%Y-%m-%dT%T%z'}
        ]
    ];
    
    $result->products->{datetime}; # DateTime object

=head2 datetime_format

check with DateTime::Format::***. for example, L<DateTime::Format::HTTP>,
L<DateTime::Format::Mail>, L<DateTime::Format::MySQL> and etc.

    my $data = {datetime => '2004-04-26 19:09:21'};

    my $rule = [
        datetime => [
            {datetime_format => 'MySQL'}
        ]
    ];

=head2 greater_than

numeric comparison

    my $rule = [
        age => [
            {greater_than => 25}
        ]
    ];

=head2 less_than

numeric comparison

    my $rule = [
        age => [
            {less_than => 25}
        ]
    ];

=head2 equal_to

numeric comparison

    my $rule = [
        age => [
            {equal_to => 25}
        ]
    ];
    
=head2 between

numeric comparison

    my $rule = [
        age => [
            {between => [1, 20]}
        ]
    ];

=head2 in_array

check if the food ordered is in menu

    my $rule = [
        food => [
            {in_array => [qw/sushi bread apple/]}
        ]
    ];

=head2 STABILITY

L<Validator::Custom::HTMLForm> is stable.
The following constraint function keep backword compatible.

    # Constraint functions
    defined
    not_defined
    not_blank
    blank
    not_space
    int
    uint
    decimal
    ascii
    length
    http_url
    selected_at_least
    regex
    duplication
    email
    email_mx
    email_loose
    email_loose_mx
    date
    time
    datetime
    datetime_strptime
    datetime_format
    greater_than
    less_than
    equal_to
    between
    in_array

=head1 AUTHOR

Yuki Kimoto, C<< <kimoto.yuki at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Yuki Kimoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

