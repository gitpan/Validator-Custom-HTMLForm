package Validator::Custom::HTMLForm::Constraints;

use strict;
use warnings;

use Carp 'croak';

sub not_defined { !defined $_[0] }
sub defined   { defined $_[0] }
sub blank     { $_[0] eq '' }
sub not_blank { $_[0] ne '' }
sub not_space { $_[0] !~ '^\s*$' ? 1 : 0 }

sub int   { $_[0] =~ /^\-?[\d]+$/        ? 1 : 0 }
sub uint  { $_[0] =~ /^\d+$/             ? 1 : 0 }
sub ascii { $_[0] =~ /^[\x21-\x7E]+$/    ? 1 : 0 }

sub shift_array {
    my $values = shift;
    
    $values = [$values] unless ref $values eq 'ARRAY';
    
    return [1, shift @$values];
}

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
    my $value;
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
            $value = $class->new(%date);
        }
        elsif ($class eq 'Time::Piece') {
            require Time::Piece;
            $value = sprintf "%04d-%02d-%02d 00:00:00", $year, $month, $day;
            $value = $class->strptime($value, "%Y-%m-%d %H:%M:%S");
        }
        else {
            $value = sprintf "%04d-%02d-%02d 00:00:00", $year, $month, $day;
        }
    }
    return [$is_valid, $value];
}

sub time {
    my ($hour, $min, $sec) = @{$_[0]};
    $hour ||= 0;
    $min  ||= 0;
    $sec  ||= 0;

    require Date::Calc;
    my $value = Date::Calc::check_time($hour, $min, $sec) ? 1 : 0;
    my $time = $value ? sprintf("%02d:%02d:%02d", $hour, $min, $sec) : undef;
    return [$value, $time];
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
    return [$is_valid, $data];
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
    return $value > $target ? 1 : 0;
}

sub less_than {
    my ($value, $target) = @_;
    
    croak "Constraint 'less_than' needs a numeric argument"
      unless defined $target && $target =~ /^\d+$/;
    
    return 0 unless $value =~ /^\d+$/;
    return $value < $target ? 1 : 0;
}

sub equal_to {
    my ($value, $target) = @_;
    
    croak "Constraint 'equal_to' needs a numeric argument"
      unless defined $target && $target =~ /^\d+$/;
    
    return 0 unless $value =~ /^\d+$/;
    return $value == $target ? 1 : 0;
}

sub between {
    my ($value, $args) = @_;
    my ($start, $end) = @$args;
    
    croak "Constraint 'between' needs two numeric arguments"
      unless defined($start) && $start =~ /^\d+$/ && defined($end) && $end =~ /^\d+$/;
    
    return 0 unless $value =~ /^\d+$/;
    return $value >= $start && $value <= $end ? 1 : 0;
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
    return [$is_valid, $dt];
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
    return [$is_valid, $dt];
}

1;

=head1 NAME

Validator::Custom::HTMLForm::Constraints - HTML Form constraint functions

=head1 CONSTRAINT FUNCTIONS

Constraint functions is explained in L<Validator::Custom::HTMLForm>

=head2 defined

=head2 not_defined

=head2 not_blank

=head2 blank

=head2 not_space

=head2 int

=head2 uint

=head2 decimal
    
=head2 ascii

=head2 length

=head2 http_url

=head2 selected_at_least

=head2 regex

=head2 duplication

=head2 shift_array

=head2 email

=head2 email_mx

=head2 email_loose

=head2 email_loose_mx

=head2 date

=head2 time

=head2 datetime

=head2 datetime_strptime

=head2 datetime_format

=head2 greater_than

=head2 less_than

=head2 equal_to

=head2 between

=head2 in_array

=head1 AUTHOR

Yuki Kimoto, C<< <kimoto.yuki at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Yuki Kimoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

