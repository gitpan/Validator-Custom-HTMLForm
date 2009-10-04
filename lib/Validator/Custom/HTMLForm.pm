package Validator::Custom::HTMLForm;
use base 'Validator::Custom';

our $VERSION = '0.0201';

use warnings;
use strict;
use Carp ();

use Validator::Custom::Trim;

__PACKAGE__->add_constraint(
    Validator::Custom::Trim->constraints,
    NOT_BLANK         => \&Validator::Custom::HTMLForm::Constraints::NOT_BLANK,
    SP                => \&Validator::Custom::HTMLForm::Constraints::SP,
    SPACE             => \&Validator::Custom::HTMLForm::Constraints::SPACE,
    INT               => \&Validator::Custom::HTMLForm::Constraints::INT,
    UINT              => \&Validator::Custom::HTMLForm::Constraints::UINT,
    ASCII             => \&Validator::Custom::HTMLForm::Constraints::ASCII,
    DUPLICATION       => \&Validator::Custom::HTMLForm::Constraints::DUPLICATION,
    LENGTH            => \&Validator::Custom::HTMLForm::Constraints::LENGTH,
    REGEX             => \&Validator::Custom::HTMLForm::Constraints::REGEX,
    EMAIL             => \&Validator::Custom::HTMLForm::Constraints::EMAIL,
    EMAIL_MX          => \&Validator::Custom::HTMLForm::Constraints::EMAIL_MX,
    EMAIL_LOOSE       => \&Validator::Custom::HTMLForm::Constraints::EMAIL_LOOSE,
    EMAIL_LOOSE_MX    => \&Validator::Custom::HTMLForm::Constraints::EMAIL_LOOSE_MX,
    DATE              => \&Validator::Custom::HTMLForm::Constraints::DATE,
    TIME              => \&Validator::Custom::HTMLForm::Constraints::TIME,
    DATETIME          => \&Validator::Custom::HTMLForm::Constraints::DATETIME,
    HTTP_URL          => \&Validator::Custom::HTMLForm::Constraints::HTTP_URL,
    SELECTED_AT_LEAST => \&Validator::Custom::HTMLForm::Constraints::SELECTED_AT_LEAST,
    GREATER_THAN      => \&Validator::Custom::HTMLForm::Constraints::GREATER_THAN,
    LESS_THAN         => \&Validator::Custom::HTMLForm::Constraints::LESS_THAN,
    EQUAL_TO          => \&Validator::Custom::HTMLForm::Constraints::EQUAL_TO,
    BETWEEN           => \&Validator::Custom::HTMLForm::Constraints::BETWEEN,
    DECIMAL           => \&Validator::Custom::HTMLForm::Constraints::DECIMAL,
    IN_ARRAY          => \&Validator::Custom::HTMLForm::Constraints::IN_ARRAY,
    DATETIME_FORMAT   => \&Validator::Custom::HTMLForm::Constraints::DATETIME_FORMAT,
    DATETIME_STRPTIME => \&Validator::Custom::HTMLForm::Constraints::DATETIME_STRPTIME,
);

package Validator::Custom::HTMLForm::Constraints;

sub NOT_BLANK {defined $_[0] && $_[0] ne '' ? 1 : 0}
sub SP    {$_[0] =~ /\s/                ? 1 : 0}
sub SPACE {$_[0] =~ /\s/                ? 1 : 0}
sub INT   {$_[0] =~ /^\-?[\d]+$/        ? 1 : 0}
sub UINT  {$_[0] =~ /^\d+$/             ? 1 : 0}
sub ASCII {$_[0] =~ /^[\x21-\x7E]+$/    ? 1 : 0}

sub DUPLICATION {
    my $values = shift;
    
    Carp::croak(qq/validation "DUPLICATION" needs two keys of data./)
      unless defined $values->[0] && defined $values->[1];
    
    return $values->[0] eq $values->[1] ? 1 : 0;
}

sub LENGTH {
    my ($value, $args) = @_;
    
    my $min;
    my $max;
    
    if(ref $args eq 'ARRAY') {
        ($min, $max) = @$args;
    }
    else {
        $min = $args;
    }
    
    Carp::croak(qq/validation "LENGTH" needs one or two arguments./)
      unless defined $min;
    
    my $length  = length $value;
    $max     ||= $min;
    $min += 0;
    $max += 0;
    return $min <= $length && $length <= $max ? 1 : 0;
}

sub REGEX {
    my ($value, $regex) = @_;
    $value =~ /$regex/ ? 1 : 0;
}

sub EMAIL {
    require Email::Valid;
    return 0 unless $_[0];
    return Email::Valid->address(-address => $_[0]) ? 1 : 0;
}

sub EMAIL_MX {
    require Email::Valid;
    return 0 unless $_[0];
    return Email::Valid->address(-address => $_[0], -mxcheck => 1) ? 1 : 0;
}

sub EMAIL_LOOSE {
    require Email::Valid::Loose;
    return 0 unless $_[0];
    return Email::Valid::Loose->address($_[0]) ? 1 : 0;
}

sub EMAIL_LOOSE_MX {
    require Email::Valid::Loose;
    return 0 unless $_[0];
    return Email::Valid::Loose->address(-address => $_[0], -mxcheck => 1) ? 1 : 0;
}

sub DATE {
    my ($values, $options) = @_;
    
    my ($year, $month, $day) = @$values;
    $options ||= {};
    
    require Date::Calc;
    my $is_valid = Date::Calc::check_date($year, $month, $day) ? 1 : 0;
    my $result;
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
            $result = $class->new(%date);
        }
        elsif ($class eq 'Time::Piece') {
            require Time::Piece;
            $result = sprintf "%04d-%02d-%02d 00:00:00", $year, $month, $day;
            $result = $class->strptime($result, "%Y-%m-%d %H:%M:%S");
        }
        else {
            $result = sprintf "%04d-%02d-%02d 00:00:00", $year, $month, $day;
        }
    }
    return ($is_valid, $result);
}

sub TIME {
    my ($hour, $min, $sec) = @{$_[0]};
    $hour ||= 0;
    $min  ||= 0;
    $sec  ||= 0;

    require Date::Calc;
    my $result = Date::Calc::check_time($hour, $min, $sec) ? 1 : 0;
    my $time = $result ? sprintf("%02d:%02d:%02d", $hour, $min, $sec) : undef;
    return ($result, $time);
}

sub DATETIME {
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

sub HTTP_URL {
    return $_[0] =~ /^s?https?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+\$,%#]+$/ ? 1 : 0;
}

sub SELECTED_AT_LEAST {
    my ($values, $num) = @_;
    
    my $selected = ref $values ? $values : [$values];
    $num += 0;
    return scalar(@$selected) >= $num ? 1 : 0;
}

sub GREATER_THAN {
    my ($value, $target) = @_;
    
    Carp::croak(qq/Validation GREATER_THAN needs a numeric argument./)
      unless defined $target && $target =~ /^\d+$/;
    
    return 0 unless $value =~ /^\d+$/;
    return ( $value > $target ) ? 1 : 0;
}

sub LESS_THAN {
    my ($value, $target) = @_;
    
    Carp::croak(qq/Validation LESS_THAN needs a numeric argument./)
      unless defined $target && $target =~ /^\d+$/;
    
    return 0 unless $value =~ /^\d+$/;
    return ( $value < $target ) ? 1 : 0;
}

sub EQUAL_TO {
    my ($value, $target) = @_;
    
    Carp::croak(qq/Validation EQUAL_TO needs a numeric argument./)
      unless defined $target && $target =~ /^\d+$/;
    
    return 0 unless $value =~ /^\d+$/;
    return ( $value == $target ) ? 1 : 0;
}

sub BETWEEN {
    my ($value, $args) = @_;
    my ($start, $end) = @$args;
    
    Carp::croak(qq/Validation BETWEEN needs two numeric arguments./)
      unless defined($start) && $start =~ /^\d+$/ && defined($end) && $end =~ /^\d+$/;
    
    return 0 unless $value =~ /^\d+$/;
    return ( $value >= $start && $value <= $end ) ? 1 : 0;
}

sub DECIMAL {
    my ($value, $digits) = @_;
    
    Carp::croak(qq/Validation DECIMAL needs one or two numeric arguments./)
      unless $digits;
    
    $digits = [$digits] unless ref $digits eq 'ARRAY';
    
    $digits->[1] ||= 0;
    
    Carp::croak(qq/Validation DECIMAL needs one or two numeric arguments./)
      unless $digits->[0] =~ /^\d+$/ && $digits->[1] =~ /^\d+$/;
    
    return 0 unless $value =~ /^\d+(\.\d+)?$/;
    my $reg = qr/^\d{1,$digits->[0]}(\.\d{0,$digits->[1]})?$/;
    return $value =~ /$reg/ ? 1 : 0;
}

sub IN_ARRAY {
    my ($value, $args) = @_;
    $value = '' unless defined $value;
    my $match = grep { $_ eq $value } @$args;
    return $match > 0 ? 1 : 0;
}

sub DATETIME_FORMAT {
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
    
    Carp::croak(qq/Validation DATETIME_FORMAT needs a format argument./)
      unless $format;
    
    my $module;
    if ( ref $format ) {
        $module = $format;
    }
    else {
        $module = "DateTime::Format::$format";
        eval "require $module";
        Carp::croak(qq/Validation DATETIME_FORMAT: failed to require $module. "$@"/)
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

sub DATETIME_STRPTIME {
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
    
    Carp::croak(qq/Validation DATETIME_STRPTIME needs a format argument./)
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
1;

=head1 NAME

Validator::Custom::HTMLForm - HTML Form validator based on Validator::Custom

=head1 VERSION

Version 0.0102

=cut

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
    
    # Validators
    my $validation_rule = [
        name => [
            'NOT_BLANK',
            'ASCII',
            {LENGTH => [1, 30]}
        ],
        age => [
            'NOT_BLANK',
            'INT'
        ],
        
        mail1  => [
            'TRIM',
            'NOT_BLANK',
            'EMAIL_LOOSE'
        ],
        mail2  => [
            'NOT_BLANK',
            'EMAIL_LOOSE'
        ],
        
        [qw/mail1 mail2/] => [
            'DUPLICATION'
        ],
        
        { date  => ['year',  'month', 'day'] } => [
            'DATE'
        ]
    ]
    
    # Create validator object
    my $vc = Validator::Custom::HTMLForm->new;
    
    # Validate
    $vc->validate($data, $validation_rule);
    
    # Get invalid key
    my @invalid_keys = $vc->invalid_keys;
    
    # Get converted result
    my $results = $vc->results;
    
    # Validators and error message
    my $validation_rule = [
        name => [
            ['NOT_BLANK',         'name must be exist'],
            ['ASCII',             'name must be acsii']
            [{LENGTH => [1, 30]}, 'name must be length 1 to 30']
        ],
        age => [
            ['NOT_BLANK',         'age must be exist'],
            ['INT',               'age must be integer value']
        ],
    ]
    
    # Get error message on one linear
    my @errors = Validator::Custom::HTMLForm->new->validate($data,$validator)->errors;

=head1 DESCRIPTION

aaa

This module usage is same as L<Validator::Custom>.

See L<Validator::Custom> document.

=head1 VALIDATION COMMANDS

=over 4

=item SP

check if the data containe space.

=item NOT_BLANK

check if the data is not blank.

=item INT

check if the data is integer.
    
    # valid data
    123
    -134

=item UINT

check if the data is unsigned integer.

    # valid data
    123
    
=item DECIMAL
    
    my $data = { num => '123.45678' };
    my $validation_rule => [
        num => [
            {'DECIMAL' => [3, 5]}
        ]
    ];

    Validator::Custom::HTMLForm->new->validate($data,$validation_rule);

each numbers (3,5) mean maximum digits before/after '.'

=item ASCII

check is the data consists of only ascii code.

=item LENGTH

check the length of the data.

The following sample check if the length of the data is 4 or not.

    my $data = { str => 'aaaa' };
    my $validation_rule => [
        num => [
            {'LENGTH' => 4}
        ]
    ];

when you set two arguments, it checks if the length of data is in
the range between 4 and 10.
    
    my $data = { str => 'aaaa' };
    my $validation_rule => [
        num => [
            {'LENGTH' => [4, 10]}
        ]
    ];

=item HTTP_URL

verify it is a http(s)-url

    my $data = { url => 'http://somehost.com' };
    my $validation_rule => [
        url => [
            'HTTP_URL'
        ]
    ];

=item SELECTED_AT_LEAST

verify the quantity of selected parameters is counted over allowed minimum.

    <input type="checkbox" name="hobby" value="music" /> Music
    <input type="checkbox" name="hobby" value="movie" /> Movie
    <input type="checkbox" name="hobby" value="game"  /> Game
    
    
    my $data = {hobby => ['music', 'movie' ]};
    my $validation_rule => [
        hobby => [
            {SELECTED_AT_LEAST => 1}
        ]
    ];

=item REGEX

check with regular expression.
    
    my $data = {str => 'aaa'};
    my $validation_rule => [
        str => [
            {REGEX => qr/a{3}/}
        ]
    ];

=item DUPLICATION

check if the two data are same or not.

    my $data = {mail1 => 'a@somehost.com', mail2 => 'a@somehost.com'};
    my $validation_rule => [
        [qw/mail1 mail2/] => [
            'DUPLICATION'
        ]
    ];

=item EMAIL

check with L<Email::Valid>.

    my $data = {mail => 'a@somehost.com'};
    my $validation_rule => [
        mail => [
            'EMAIL'
        ]
    ];

=item EMAIL_MX

check with L<Email::Valid>, including  mx check.

    my $data = {mail => 'a@somehost.com'};
    my $validation_rule => [
        mail => [
            'EMAIL_MX'
        ]
    ];

=item EMAIL_LOOSE

check with L<Email::Valid::Loose>.

    my $data = {mail => 'a.@somehost.com'};
    my $validation_rule => [
        mail => [
            'EMAIL_LOOSE'
        ]
    ];

=item EMAIL_LOOSE_MX

    my $data = {mail => 'a.@somehost.com'};
    my $validation_rule => [
        mail => [
            'EMAIL_LOOSE'
        ]
    ];

=item DATE

check with L<Date::Calc>

    my $data = {year => '2009', month => '12', day => '13'};
    my $validation_rule => [
        {date => [qw/year month day/]} => [
            'DATE'
        ]
    ];
    
    $vc->results->{date}; # 2009-12-13 00:00:00

You can specify options

    # Convert DateTime object
    my $validation_rule => [
        {date => [qw/year month day/]} => [
            ['DATE', {'datetime_class' => 'DateTime', time_zone => 'Asia/Tokyo'}]
        ]
    ];
    
    $vc->results->{date}; # DateTime object


    # Convert Time::Piece object
    my $validation_rule => [
        {date => [qw/year month day/]} => [
            ['DATE', {'datetime_class' => 'Time::Piece'}]
        ]
    ];
    
    $vc->results->{date}; # Time::Piece object

=item TIME

check with L<Date::Calc>

    my $data = {hour => '12', minute => '40', second => '13'};
    my $validation_rule => [
        [qw/hour minute second/] => [
            'TIME'
        ]
    ];

=item DATETIME

check with L<Date::Calc>

    my $data = {
        year => '2009', month => '12',  day => '13'
        hour => '12',   minute => '40', second => '13'
    };
    my $validation_rule => [
        {datetime => [qw/year month day hour minute second/]} => [
            'DATETIME'
        ]
    ];
    
    $vc->results->{datetime}; # 2009-12-13 12:40:13

You can specify options

    # Convert DateTime object
    my $validation_rule => [
        {datetime => [qw/year month day hour minute second/]} => [
            ['DATETIME', {'datetime_class' => 'DateTime', time_zone => 'Asia/Tokyo'}]
        ]
    ];
    
    $vc->results->{date}; # DateTime object


    # Convert Time::Piece object
    my $validation_rule => [
        {datetime => [qw/year month day hour minute second/]} => [
            ['DATETIME', {'datetime_class' => 'Time::Piece'}]
        ]
    ];
    
    $vc->results->{date}; # Time::Piece object

=item DATETIME_STRPTIME

check with L<DateTime::Format::Strptime>.

    my $data = {datetime => '2006-04-26T19:09:21+0900'};

    my $validation_rule => [
        datetime => [
            {'DATETIME' => '%Y-%m-%dT%T%z'}
        ]
    ];
    
    $vc->results->{datetime}; # DateTime object

=item DATETIME_FORMAT

check with DateTime::Format::***. for example, L<DateTime::Format::HTTP>,
L<DateTime::Format::Mail>, L<DateTime::Format::MySQL> and etc.

    my $data = {datetime => '2004-04-26 19:09:21'};

    my $validation_rule = [
        datetime => [
            {DATETIME_FORMAT => 'MySQL'}
        ]
    ];

=item GREATER_THAN

numeric comparison

    my $validation_rule = [
        age => [
            {GREATER_THAN => 25}
        ]
    ];

=item LESS_THAN

numeric comparison

    my $validation_rule = [
        age => [
            {LESS_THAN => 25}
        ]
    ];

=item EQUAL_TO

numeric comparison

    my $validation_rule = [
        age => [
            {EQUAL_TO => 25}
        ]
    ];
    
=item BETWEEN

numeric comparison

    my $validation_rule = [
        age => [
            {BETWEEN => [1, 20]}
        ]
    ];

=item IN_ARRAY

check if the food ordered is in menu

    my $validation_rule = [
        food => [
            {IN_ARRAY => [qw/sushi bread apple/]}
        ]
    ];

=item TRIM

Trim leading and trailing white space

=item TRIM_LEAD

Trim leading white space

=item TRIM_TRAIL

Trim trailing white space

=item TRIM_COLLAPSE

Trim leading and trailing white space, and collapse all whitespace characters into a single space.

=back

=head1 AUTHOR

Yuki Kimoto, C<< <kimoto.yuki at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-validator-custom-htmlform at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Validator-Custom-HTMLForm>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Validator::Custom::HTMLForm


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Validator-Custom-HTMLForm>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Validator-Custom-HTMLForm>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Validator-Custom-HTMLForm>

=item * Search CPAN

L<http://search.cpan.org/dist/Validator-Custom-HTMLForm/>

=back


=head1 SEE ALSO

L<Validator::Custom>, L<Validator::Custom::Trim>

L<FormValidator::Custom>, L<Data::FormValidator>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Yuki Kimoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Validator::Custom::HTMLForm

