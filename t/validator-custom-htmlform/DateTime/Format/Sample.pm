package DateTime::Format::Sample;
use strict;
use warnings;

sub new {bless {}, __PACKAGE__}

sub parse_datetime {
    my ($self,$format) = @_;
    my ($year, $month, $day, $hour, $minute, $second) =
      $format =~ m#^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})$#;
    
    require DateTime;
    
    return DateTime->new(
        year   => $year,
        month  => $month,
        day    => $day,
        hour   => $hour,
        minute => $minute,
        second => $second,
    );
}

1;
