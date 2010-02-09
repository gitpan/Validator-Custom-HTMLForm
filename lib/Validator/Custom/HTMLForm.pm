package Validator::Custom::HTMLForm;

use warnings;
use strict;

use base 'Validator::Custom';

use Validator::Custom::Trim;

__PACKAGE__->add_constraint(
    %{Validator::Custom::Trim->constraints},
    defined           => \&Validator::Custom::HTMLForm::Constraints::defined,
    not_space         => \&Validator::Custom::HTMLForm::Constraints::not_space,
    not_blank         => \&Validator::Custom::HTMLForm::Constraints::not_blank,
    sp                => \&Validator::Custom::HTMLForm::Constraints::sp,
    space             => \&Validator::Custom::HTMLForm::Constraints::space,
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

package Validator::Custom::HTMLForm::Constraints;

use strict;
use warnings;

use Carp 'croak';

sub defined   {defined $_[0]}
sub not_blank {$_[0] ne ''      ? 1 : 0}
sub not_space {$_[0] !~ '^\s*$' ? 1 : 0}

sub int   {$_[0] =~ /^\-?[\d]+$/        ? 1 : 0}
sub uint  {$_[0] =~ /^\d+$/             ? 1 : 0}
sub ascii {$_[0] =~ /^[\x21-\x7E]+$/    ? 1 : 0}

sub duplication {
    my $values = shift;
    
    croak "Constraint 'duplication' needs two keys of data"
      unless defined $values->[0] && defined $values->[1];
    
    return $values->[0] eq $values->[1] ? 1 : 0;
}

sub length {
    my ($value, $args) = @_;
    
    
    my $min;
    my $max;
    
    if(ref $args eq 'ARRAY') {
        ($min, $max) = @$args;
    }
    else {
        $min = $args;
    }
    
    croak "Constraint 'length' needs one or two arguments"
      unless defined $min;
    
    my $length  = length $value;
    $max     ||= $min;
    $min += 0;
    $max += 0;
    return $min <= $length && $length <= $max ? 1 : 0;
}

sub regex {
    my ($value, $regex) = @_;
    $value =~ /$regex/ ? 1 : 0;
}

sub email {
    require Email::Valid;
    return 0 unless $_[0];
    return Email::Valid->address(-address => $_[0]) ? 1 : 0;
}

sub email_mx {
    require Email::Valid;
    return 0 unless $_[0];
    return Email::Valid->address(-address => $_[0], -mxcheck => 1) ? 1 : 0;
}

sub email_loose {
    require Email::Valid::Loose;
    return 0 unless $_[0];
    return Email::Valid::Loose->address($_[0]) ? 1 : 0;
}

sub email_loose_mx {
    require Email::Valid::Loose;
    return 0 unless $_[0];
    return Email::Valid::Loose->address(-address => $_[0], -mxcheck => 1) ? 1 : 0;
}

sub date {
    my ($values, $options) = @_;
    
    my ($year, $month, $day) = @$values;
    $options ||= {};
    
    require Date::Calc;
    my $is_valid = Date::Calc::check_date($year, $month, $day) ? 1 : 0;
    my $product;
    if ($is_valid) {
        my $class = $options->{datetime_class} || '';
        if ($class eq 'DateTime') {
            require DateTime;

            my %date = (
                year  => $year,
                month => $month,
                day   => $day,
            );
            if ($options->{time_zone}) {
                $date{time_zone} = $options->{time_zone};
            }
            $product = $class->new(%date);
        }
        elsif ($class eq 'Time::Piece') {
            require Time::Piece;
            $product = sprintf "%04d-%02d-%02d 00:00:00", $year, $month, $day;
            $product = $class->strptime($product, "%Y-%m-%d %H:%M:%S");
        }
        else {
            $product = sprintf "%04d-%02d-%02d 00:00:00", $year, $month, $day;
        }
    }
    return ($is_valid, $product);
}

sub time {
    my ($hour, $min, $sec) = @{$_[0]};
    $hour ||= 0;
    $min  ||= 0;
    $sec  ||= 0;

    require Date::Calc;
    my $product = Date::Calc::check_time($hour, $min, $sec) ? 1 : 0;
    my $time = $product ? sprintf("%02d:%02d:%02d", $hour, $min, $sec) : undef;
    return ($product, $time);
}

sub datetime {
    my ($values, $options) = @_;
    my ($year, $month, $day, $hour, $min, $sec) = @$values;
    $options ||= {};
    
    $hour ||= 0;
    $min  ||= 0;
    $sec  ||= 0;
    my $is_valid = Date::Calc::check_date($year, $month, $day)
              && Date::Calc::check_time($hour, $min,   $sec) ? 1 : 0;
    my $data;
    if ($is_valid) {
        my $class = $options->{datetime_class} || '';
        if ($class eq 'DateTime') {
            require DateTime;
            
            my %date = (
                year   => $year,
                month  => $month,
                day    => $day,
                hour   => $hour,
                minute => $min,
                second => $sec,
            );
            if ($options->{time_zone}) {
                $date{time_zone} = $options->{time_zone};
            }
            $data = $class->new(%date);
        }
        elsif ($class eq 'Time::Piece') {
            require Time::Piece;
            
            $data = sprintf "%04d-%02d-%02d %02d:%02d:%02d",
                $year, $month, $day, $hour, $min, $sec;
            $data = $class->strptime($data, "%Y-%m-%d %H:%M:%S");
        }
        else {
            $data = sprintf "%04d-%02d-%02d %02d:%02d:%02d",
                $year, $month, $day, $hour, $min, $sec;
        }
    }
    return ($is_valid, $data);
}

sub http_url {
    return $_[0] =~ /^s?https?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+\$,%#]+$/ ? 1 : 0;
}

sub selected_at_least {
    my ($values, $num) = @_;
    
    my $selected = ref $values ? $values : [$values];
    $num += 0;
    return scalar(@$selected) >= $num ? 1 : 0;
}

sub greater_than {
    my ($value, $target) = @_;
    
    croak "Constraint 'greater_than' needs a numeric argument"
      unless defined $target && $target =~ /^\d+$/;
    
    return 0 unless $value =~ /^\d+$/;
    return ( $value > $target ) ? 1 : 0;
}

sub less_than {
    my ($value, $target) = @_;
    
    croak "Constraint 'less_than' needs a numeric argument"
      unless defined $target && $target =~ /^\d+$/;
    
    return 0 unless $value =~ /^\d+$/;
    return ( $value < $target ) ? 1 : 0;
}

sub equal_to {
    my ($value, $target) = @_;
    
    croak "Constraint 'equal_to' needs a numeric argument"
      unless defined $target && $target =~ /^\d+$/;
    
    return 0 unless $value =~ /^\d+$/;
    return ( $value == $target ) ? 1 : 0;
}

sub between {
    my ($value, $args) = @_;
    my ($start, $end) = @$args;
    
    croak "Constraint 'between' needs two numeric arguments"
      unless defined($start) && $start =~ /^\d+$/ && defined($end) && $end =~ /^\d+$/;
    
    return 0 unless $value =~ /^\d+$/;
    return ( $value >= $start && $value <= $end ) ? 1 : 0;
}

sub decimal {
    my ($value, $digits) = @_;
    
    croak "Constraint 'decimal' needs one or two numeric arguments"
      unless $digits;
    
    $digits = [$digits] unless ref $digits eq 'ARRAY';
    
    $digits->[1] ||= 0;
    
    croak "Constraint 'decimal' needs one or two numeric arguments"
      unless $digits->[0] =~ /^\d+$/ && $digits->[1] =~ /^\d+$/;
    
    return 0 unless $value =~ /^\d+(\.\d+)?$/;
    my $reg = qr/^\d{1,$digits->[0]}(\.\d{0,$digits->[1]})?$/;
    return $value =~ /$reg/ ? 1 : 0;
}

sub in_array {
    my ($value, $args) = @_;
    $value = '' unless defined $value;
    my $match = grep { $_ eq $value } @$args;
    return $match > 0 ? 1 : 0;
}

sub datetime_format {
    my ($date, $arg) = @_;
    
    my $format;
    my $options;
    if (ref $arg eq 'ARRAY') {
        ($format, $options) = @$arg;
    }
    else {
        $format = $arg;
    }
    
    $options ||= {};        
    
    croak "Constraint 'datetime_format' needs a format argument"
      unless $format;
    
    my $module;
    if ( ref $format ) {
        $module = $format;
    }
    else {
        $module = "DateTime::Format::$format";
        eval "require $module";
        croak "Constraint 'datetime_format': failed to require $module. $@"
          if $@;
    }
    my $dt;
    eval {
        $dt = $module->parse_datetime($date);
    };
    my $is_valid = $dt ? 1 : 0;
    
    if ( $dt && $options->{time_zone} ) {
        $dt->set_time_zone( $options->{time_zone} );
    }
    return ($is_valid, $dt);
}

sub datetime_strptime {
    my ($date, $arg) = @_;
    
    my $format;
    my $options;
    if (ref $arg eq 'ARRAY') {
        ($format, $options) = @$arg;
    }
    else {
        $format = $arg;
    }
    
    $options ||= {};
    
    croak "Constraint 'datetime_strptime' needs a format argument"
      unless $format;
    my $dt;
    
    require DateTime::Format::Strptime;
    eval{
        my $strp = DateTime::Format::Strptime->new(
            pattern => $format,
            on_error => 'croak'
        );
        $dt = $strp->parse_datetime($date);
    };
    
    my $is_valid = $dt ? 1 : 0;
    
    if ( $dt && $options->{time_zone} ) {
        $dt->set_time_zone( $options->{time_zone} );
    }
    return ($is_valid, $dt);
}

package Validator::Custom::HTMLForm;

1;

=head1 NAME

Validator::Custom::HTMLForm - HTML Form validator

=head1 Version

Version 0.0503

=cut

our $VERSION = '0.0503';

=head1 STATE

L<Validator::Custom::HTMLForm> is not stable.

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

=head1 METHODS

This module is L<Validator::Custom> subclass.
All methods of L<Validator::Custom> is available.

=head1 Constraint functions

L<Validator::Custom::Trim> all constraint functions are available

=over 4

=item defined

check if the data is defined.

=item not_blank

check if the data is not blank.

=item not_space

check if the data do not containe space.

=item int

check if the data is integer.
    
    # valid data
    123
    -134

=item uint

check if the data is unsigned integer.

    # valid data
    123
    
=item decimal
    
    my $data = { num => '123.45678' };
    my $rule => [
        num => [
            {'decimal' => [3, 5]}
        ]
    ];

    Validator::Custom::HTMLForm->new->validate($data,$rule);

each numbers (3,5) mean maximum digits before/after '.'

=item ascii

check is the data consists of only ascii code.

=item length

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

=item http_url

verify it is a http(s)-url

    my $data = { url => 'http://somehost.com' };
    my $rule => [
        url => [
            'http_url'
        ]
    ];

=item selected_at_least

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

=item regex

check with regular expression.
    
    my $data = {str => 'aaa'};
    my $rule => [
        str => [
            {regex => qr/a{3}/}
        ]
    ];

=item duplication

check if the two data are same or not.

    my $data = {mail1 => 'a@somehost.com', mail2 => 'a@somehost.com'};
    my $rule => [
        [qw/mail1 mail2/] => [
            'duplication'
        ]
    ];

=item email

check with L<Email::Valid>.

    my $data = {mail => 'a@somehost.com'};
    my $rule => [
        mail => [
            'email'
        ]
    ];

=item email_mx

check with L<Email::Valid>, including  mx check.

    my $data = {mail => 'a@somehost.com'};
    my $rule => [
        mail => [
            'email_mx'
        ]
    ];

=item email_loose

check with L<Email::Valid::Loose>.

    my $data = {mail => 'a.@somehost.com'};
    my $rule => [
        mail => [
            'email_loose'
        ]
    ];

=item email_loose_mx

    my $data = {mail => 'a.@somehost.com'};
    my $rule => [
        mail => [
            'email_loose'
        ]
    ];

=item date

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

=item time

check with L<Date::Calc>

    my $data = {hour => '12', minute => '40', second => '13'};
    my $rule => [
        [qw/hour minute second/] => [
            'time'
        ]
    ];

=item datetime

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

=item datetime_strptime

check with L<DateTime::Format::Strptime>.

    my $data = {datetime => '2006-04-26T19:09:21+0900'};

    my $rule => [
        datetime => [
            {'datetime_strptime' => '%Y-%m-%dT%T%z'}
        ]
    ];
    
    $result->products->{datetime}; # DateTime object

=item datetime_format

check with DateTime::Format::***. for example, L<DateTime::Format::HTTP>,
L<DateTime::Format::Mail>, L<DateTime::Format::MySQL> and etc.

    my $data = {datetime => '2004-04-26 19:09:21'};

    my $rule = [
        datetime => [
            {datetime_format => 'MySQL'}
        ]
    ];

=item greater_than

numeric comparison

    my $rule = [
        age => [
            {greater_than => 25}
        ]
    ];

=item less_than

numeric comparison

    my $rule = [
        age => [
            {less_than => 25}
        ]
    ];

=item equal_to

numeric comparison

    my $rule = [
        age => [
            {equal_to => 25}
        ]
    ];
    
=item between

numeric comparison

    my $rule = [
        age => [
            {between => [1, 20]}
        ]
    ];

=item in_array

check if the food ordered is in menu

    my $rule = [
        food => [
            {in_array => [qw/sushi bread apple/]}
        ]
    ];

=back

=head1 AUTHOR

Yuki Kimoto, C<< <kimoto.yuki at gmail.com> >>

=head1 SEE ALSO

L<Validator::Custom>, L<Validator::Custom::Trim>

L<FormValidator::Simple>, L<Data::FormValidator>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Yuki Kimoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

