package Validator::Custom::HTMLForm::Constraints;

use strict;
use warnings;

use Carp 'croak';

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

=head2 C<email>

=head2 C<email_mx>

=head2 C<email_loose>

=head2 C<email_loose_mx>

=head2 C<date>

=head2 C<time>

=head2 C<datetime>

=head2 C<datetime_strptime>

=head2 C<datetime_format>

=head1 AUTHOR

Yuki Kimoto, C<< <kimoto.yuki at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Yuki Kimoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

