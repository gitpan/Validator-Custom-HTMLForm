use Test::More 'no_plan';

use strict;
use warnings;

use Validator::Custom::HTMLForm;

use lib 't/01-core';
use DateTime::Format::Sample;

my @infos = (
    [
        'not_defined',
        {
            k1 => undef,
            k2 => 'a',
        },
        [
            k1 => [
                'not_defined'
            ],
            k2 => [
                'not_defined'
            ],
        ],
        [qw/k2/]
    ],
    [
        'defined',
        {
            k1 => undef,
            k2 => 'a',
        },
        [
            k1 => [
                'defined'
            ],
            k2 => [
                'defined'
            ],
        ],
        [qw/k1/]
    ],
    [
        'not_space',
        {
            k1 => '',
            k2 => ' ',
            k3 => ' a '
        },
        [
            k1 => [
                'not_space'
            ],
            k2 => [
                'not_space'
            ],
            k3 => [
                'not_space'
            ],
        ],
        [qw/k1 k2/]
    ],
    [
        'not_blank',
        {
            k1 => '',
            k2 => 'a',
            k3 => ' '
        },
        [
            k1 => [
                'not_blank'
            ],
            k2 => [
                'not_blank'
            ],
            k3 => [
                'not_blank'
            ],
        ],
        [qw/k1/]
    ],
    [
        'blank',
        {
            k1 => '',
            k2 => 'a',
            k3 => ' '
        },
        [
            k1 => [
                'blank'
            ],
            k2 => [
                'blank'
            ],
            k3 => [
                'blank'
            ],
        ],
        [qw/k2 k3/]
    ],    
    [
        'int',
        {
            k8  => '19',
            k9  => '-10',
            k10 => 'a',
            k11 => '10.0',
        },
        [
            k8 => [
                'int'
            ],
            k9 => [
                'int'
            ],
            k10 => [
                'int'
            ],
            k11 => [
                'int'
            ],
        ],
        [qw/k10 k11/]
    ],
    [
        'uint',
        {
            k12  => '19',
            k13  => '-10',
            k14 => 'a',
            k15 => '10.0',
        },
        [
            k12 => [
                'uint'
            ],
            k13 => [
                'uint'
            ],
            k14 => [
                'uint'
            ],
            k15 => [
                'uint'
            ],
        ],
        [qw/k13 k14 k15/]
    ],
    [
        'ascii',
        {
            k16 => '!~',
            k17 => ' ',
            k18 => "\0x7f",
        },
        [
            k16 => [
                'ascii'
            ],
            k17 => [
                'ascii'
            ],
            k18 => [
                'ascii'
            ],
        ],
        [qw/k17 k18/]
    ],
    [
        'length',
        {
            k19 => '111',
            k20 => '111',
        },
        [
            k19 => [
                {'length' => [3, 4]},
                {'length' => [2, 3]},
                {'length' => [3]},
                {'length' => 3},
            ],
            k20 => [
                {'length' => [4, 5]},
            ]
        ],
        [qw/k20/],
    ],
    [
        'duplication',
        {
            k1_1 => 'a',
            k1_2 => 'a',
            
            k2_1 => 'a',
            k2_2 => 'b'
        },
        [
            {k1 => [qw/k1_1 k1_2/]} => [
                'duplication'
            ],
            {k2 => [qw/k2_1 k2_2/]} => [
                'duplication'
            ]
        ],
        [qw/k2/]
    ],
    [
        'regex',
        {
            k1 => 'aaa',
            k2 => 'aa',
        },
        [
            k1 => [
                {'regex' => "a{3}"}
            ],
            k2 => [
                {'regex' => "a{4}"}
            ]
        ],
        [qw/k2/]
    ],
    [
        'email',
        {
            k1 => 'a@yahoo.com',
            k2 => 'a@b@c',
            k3 => '',
        },
        [
            k1 => [
                'email'
            ],
            k2 => [
                'email'
            ],
            k3 => [
                'email'
            ]
        ],
        [qw/k2 k3/]
    ],
    #[
    #    'email_mx',
    #    {
    #        k1 => 'a@yahoo.com',
    #        k2 => 'a@b@c',
    #        k3 => '',
    #    },
    #    [
    #        k1 => [
    #            'email_mx'
    #        ],
    #        k2 => [
    #            'email_mx'
    #        ],
    #        k3 => [
    #            'email_mx'
    #        ]
    #    ],
    #    [qw/k2 k3/]
    #],
    [
        'email_loose',
        {
            k1 => 'a.@yahoo.com',
            k2 => 'a@b@c',
            k3 => '',
        },
        [
            k1 => [
                'email_loose'
            ],
            k2 => [
                'email_loose'
            ],
            k3 => [
                'email_loose'
            ]
        ],
        [qw/k2 k3/]
    ],
    #[
    #    'email_loose_mx',
    #    {
    #        k1 => 'a.@yahoo.com',
    #        k2 => 'a@b@c',
    #        k3 => '',
    #    },
    #    [
    #        k1 => [
    #            'email_loose_mx'
    #        ],
    #        k2 => [
    #            'email_loose_mx'
    #        ],
    #        k3 => [
    #            'email_loose_mx'
    #        ]
    #    ],
    #    [qw/k2 k3/]
    #],
    [
        'date',
        {
            k1_year => 2000,
            k1_month  => 1,
            k1_day  => 2,
            
            k2_year => 2000,
            k2_month => 10,
            k2_day  => 40,
            
            k3_year => 2000,
            k3_month  => 1,
            k3_day  => 2,
            
            k4_year => 2000,
            k4_month  => 1,
            k4_day  => 2,
            
            k5_year => 2000,
            k5_month  => 1,
            k5_day  => 2,
        },
        [
            {k1 => [qw/k1_year k1_month k1_day/]} => [
                'date'
            ],
            {k2 => [qw/k2_year k2_month k2_day/]} => [
                'date'
            ],
            {k3 => [qw/k3_year k3_month k3_day/]} => [
                {'date' => {datetime_class => 'DateTime', time_zone => 'Asia/Tokyo'}}
            ],
            {k4 => [qw/k4_year k4_month k4_day/]} => [
                {'date' => {datetime_class => 'Time::Piece'}}
            ],
            {k5 => [qw/k5_year k5_month k5_day/]} => [
                {'date' => {datetime_class => 'DateTime'}}
            ],
        ],
        [qw/k2/],
        sub {
            my $r = shift;
            my $products = $r->products;
            is($products->{k1}, '2000-01-02 00:00:00', 'timezone');
            
            isa_ok($products->{k3}, 'DateTime');
            is($products->{k3}->time_zone->name, 'Asia/Tokyo', 'timezone');
            is($products->{k3}->year, 2000, 'timezone');
            is($products->{k3}->month, 1, 'timezone');
            is($products->{k3}->day, 2, 'timezone');
           
            isa_ok($products->{k4}, 'Time::Piece');
            is($products->{k4}->year, 2000, 'timezone');
            is($products->{k4}->mon, 1, 'timezone');
            is($products->{k4}->mday, 2, 'timezone');
        }
    ],
    [
        'time',
        {
            k1_hour   => 1,
            k1_minute => 2,
            k1_second => 3,
            
            k2_hour   => undef,
            k2_minute => undef,
            k2_second => undef,
            
            k3_hour   => 25,
            k3_minute => 1,
            k3_second => 2,
        },
        [
            {k1 => [qw/k1_hour k1_minute k1_second/]} => [
                'time'
            ],
            {k2 => [qw/k2_hour k2_minute k2_second/]} => [
                'time'
            ],
            {k3 => [qw/k3_hour k3_minute k3_second/]} => [
                'time'
            ]
        ],
        [qw/k3/],
        {
            k1 => '01:02:03',
            k2 => '00:00:00'
        }
    ],
    [
        'datetime',
        {
            k1_year => 2000,
            k1_month  => 1,
            k1_day  => 2,
            k1_hour   => 3,
            k1_minute => 4,
            k1_second => 5,
            
            k2_year => 2000,
            k2_month  => 40,
            k2_day  => 1,
            k2_hour   => 1,
            k2_minute => 1,
            k2_second => 1,
            
            k3_year => 2000,
            k3_month  =>  1,
            k3_day  => 1,
            k3_hour   => 25,
            k3_minute => 1,
            k3_second => 1,
            
            k4_year => 2000,
            k4_month  =>  1,
            k4_day  => 1,
            k4_hour   => undef,
            k4_minute => undef,
            k4_second => undef,
            
            k5_year => 2000,
            k5_month  => 1,
            k5_day  => 2,
            k5_hour   => 3,
            k5_minute => 4,
            k5_second => 5,
            
            k6_year => 2000,
            k6_month  => 1,
            k6_day  => 2,
            k6_hour   => 3,
            k6_minute => 4,
            k6_second => 5,
            
            k7_year => 2000,
            k7_month  => 1,
            k7_day  => 2,
            k7_hour   => 3,
            k7_minute => 4,
            k7_second => 5,
        },
        
        [
            {k1 => [qw/k1_year k1_month k1_day k1_hour k1_minute k1_second/ ]} => [
                'datetime'
            ],
            {k2 => [qw/k2_year k2_month k2_day k2_hour k2_minute k2_second/ ]} => [
                'datetime'
            ],
            {k3 => [qw/k3_year k3_month k3_day k3_hour k3_minute k3_second/ ]} => [
                'datetime'
            ],
            {k4 => [qw/k4_year k4_month k4_day k4_hour k4_minute k4_second/ ]} => [
                'datetime'],
            {k5 => [qw/k5_year k5_month k5_day k5_hour k5_minute k5_second/ ]} => [
                {'datetime' => {datetime_class => 'DateTime', time_zone => 'Asia/Tokyo'}}
            ],
            {k6 => [qw/k6_year k6_month k6_day k6_hour k6_minute k6_second/ ]} => [
                {'datetime' => {datetime_class => 'Time::Piece'}}
            ],
            {k7 => [qw/k5_year k7_month k7_day k7_hour k7_minute k7_second/ ]} => [
                {'datetime' => {datetime_class => 'DateTime'}}
            ],
        ],
        [qw/k2 k3/],
        sub {
            my $vc = shift;
            my $products = $vc->products;
            is($products->{k1}, '2000-01-02 03:04:05', 'timezone');
            
            is($products->{k4}, '2000-01-01 00:00:00', 'timezone');
            
            isa_ok($products->{k5}, 'DateTime');
            is($products->{k5}->time_zone->name, 'Asia/Tokyo', 'timezone');
            is($products->{k5}->year, 2000, 'timezone');
            is($products->{k5}->month, 1, 'timezone');
            is($products->{k5}->day, 2, 'timezone');
            is($products->{k5}->hour, 3, 'timezone');
            is($products->{k5}->minute, 4, 'timezone');
            is($products->{k5}->second, 5, 'timezone');
            
            isa_ok($products->{k6}, 'Time::Piece');
            is($products->{k6}->year, 2000, 'timezone');
            is($products->{k6}->mon, 1, 'timezone');
            is($products->{k6}->mday, 2, 'timezone');
            is($products->{k6}->hour, 3, 'timezone');
            is($products->{k6}->minute, 4, 'timezone');
            is($products->{k6}->second, 5, 'timezone');
        }
    ],
    [
        'http_url',
        {
            k1 => 'http://www.lost-season.jp/mt/',
            k2 => 'iii',
        },
        [
            k1 => [
                'http_url'
            ],
            k2 => [
                'http_url'
            ]
        ],
        [qw/k2/]
    ],
    [
        'selected_at_least',
        {
            k1 => 1,
            k2 =>[1],
            k3 => [1, 2],
            k4 => [],
            k5 => [1,2]
        },
        [
            k1 => [
                {selected_at_least => 1}
            ],
            k2 => [
                {selected_at_least => 1}
            ],
            k3 => [
                {selected_at_least => 2}
            ],
            k4 => [
                'selected_at_least'
            ],
            k5 => [
                {'selected_at_least' => 3}
            ]
        ],
        [qw/k5/]
    ],
    [
        'greater_than',
        {
            k1 => 5,
            k2 => 5,
            k3 => 'a',
        },
        [
            k1 => [
                {'greater_than' => 5}
            ],
            k2 => [
                {'greater_than' => 4}
            ],
            k3 => [
                {'greater_than' => 1}
            ]
        ],
        [qw/k1 k3/]
    ],
    [
        'less_than',
        {
            k1 => 5,
            k2 => 5,
            k3 => 'a',
        },
        [
            k1 => [
                {'less_than' => 5}
            ],
            k2 => [
                {'less_than' => 6}
            ],
            k3 => [
                {'less_than' => 1}
            ]
        ],
        [qw/k1 k3/]
    ],
    [
        'equal_to',
        {
            k1 => 5,
            k2 => 5,
            k3 => 'a',
        },
        [
            k1 => [
                {'equal_to' => 5}
            ],
            k2 => [
                {'equal_to' => 4}
            ],
            k3 => [
                {'equal_to' => 1}
            ]
        ],
        [qw/k2 k3/]
    ],
    [
        'between',
        {
            k1 => 5,
            k2 => 5,
            k3 => 5,
            k4 => 5,
            k5 => 'a',
        },
        [
            k1 => [
                {'between' => [5, 6]}
            ],
            k2 => [
                {'between' => [4, 5]}
            ],
            k3 => [
                {'between' => [6, 7]}
            ],
            k4 => [
                {'between' => [5, 5]}
            ],
            k5 => [
                {'between' => [5, 5]}
            ]
        ],
        [qw/k3 k5/]
    ],
    [
        'decimal',
        {
            k1 => '12.123',
            k2 => '12.123',
            k3 => '12.123',
            k4 => '12',
            k5 => '123',
            k6 => '123.a',
        },
        [
            k1 => [
                {'decimal' => [2,3]}
            ],
            k2 => [
                {'decimal' => [1,3]}
            ],
            k3 => [
                {'decimal' => [2,2]}
            ],
            k4 => [
                {'decimal' => [2]}
            ],
            k5 => [
                {'decimal' => 2}
            ],
            k6 => [
                {'decimal' => 2}
            ]
        ],
        [qw/k2 k3 k5 k6/]
    ],
    [
        'in_array',
        {
            k1 => 'a',
            k2 => 'a',
            k3 => undef
        },
        [
            k1 => [
                {'in_array' => [qw/a b/]}
            ],
            k2 => [
                {'in_array' => [qw/b c/]}
            ],
            k3 => [
                {'in_array' => [qw/b c/]}
            ]
        ],
        [qw/k2 k3/]
    ],
    [
        'datetime_format' => {
            k1 => '2000-01-02 03:04:05',
            k2 => '2000-01-02 03:04:05',
            k3 => '2000-01-02 03:04:05',
            k4 => '2000-01-02 03:04:05',
            k5 => '2000-01-01 40:01:01',
        },
        [
            k1 => [
                {'datetime_format' => 'Sample'}
            ],
            k2 => [
                {'datetime_format' => ['Sample']}
            ],
            k3 => [
                {'datetime_format' => ['Sample', {time_zone => 'Asia/Tokyo'}]}
            ],
            k4 => [
                {'datetime_format' => DateTime::Format::Sample->new}
            ],
            k5 => [
                {'datetime_format' => 'Sample'}
            ],
        ],
        [qw/k5/],
        sub {
            my $vc = shift;
            my $products = $vc->products;
            isa_ok($products->{k1}, 'DateTime');
            is($products->{k1}->year, 2000);
            is($products->{k1}->month, 1);
            is($products->{k1}->day, 2);
            is($products->{k1}->hour, 3);
            is($products->{k1}->minute, 4);
            is($products->{k1}->second, 5);
            
            isa_ok($products->{k2}, 'DateTime');
            is($products->{k2}->year, 2000);
            is($products->{k2}->month, 1);
            is($products->{k2}->day, 2);
            is($products->{k2}->hour, 3);
            is($products->{k2}->minute, 4);
            is($products->{k2}->second, 5);

            isa_ok($products->{k3}, 'DateTime');
            is($products->{k3}->year, 2000);
            is($products->{k3}->month, 1);
            is($products->{k3}->day, 2);
            is($products->{k3}->hour, 3);
            is($products->{k3}->minute, 4);
            is($products->{k3}->second, 5);
            is($products->{k3}->time_zone->name, 'Asia/Tokyo');
            
            isa_ok($products->{k4}, 'DateTime');
            is($products->{k4}->year, 2000);
            is($products->{k4}->month, 1);
            is($products->{k4}->day, 2);
            is($products->{k4}->hour, 3);
            is($products->{k4}->minute, 4);
            is($products->{k4}->second, 5);
        }
    ],
    [
        'datetime_format' => {
            k1 => '01:02:03',
            k2 => '01:02:03',
            k3 => '01:02:03',
            k4 => '25:00:00',
        },        
        [
            k1 => [
                {'datetime_strptime' => '%T'}
            ],
            k2 => [
                {'datetime_strptime' => ['%T']}
            ],
            k3 => [
                {'datetime_strptime' => ['%T', {time_zone => 'Asia/Tokyo'}]}
            ],
            k4 => [
                {'datetime_strptime' => '%T'}
            ],
        ],
        [qw/k4/],
        sub {
            my $vc = shift;
            my $products = $vc->products;
            isa_ok($products->{k1}, 'DateTime');
            is($products->{k1}->hour, 1);
            is($products->{k1}->minute, 2);
            is($products->{k1}->second, 3);
            
            isa_ok($products->{k2}, 'DateTime');
            is($products->{k2}->hour, 1);
            is($products->{k2}->minute, 2);
            is($products->{k2}->second, 3);

            isa_ok($products->{k3}, 'DateTime');
            is($products->{k3}->hour, 1);
            is($products->{k3}->minute, 2);
            is($products->{k3}->second, 3);
            is($products->{k3}->time_zone->name, 'Asia/Tokyo');
        },
    ],
    [
        'trim',
        {
            int_param => ' 123 ',
            collapse  => "  \n a \r\n b\nc  \t",
            left      => '  abc  ',
            right     => '  def  '
        },
        [
            int_param => [
                'trim'
            ],
            collapse  => [
                'trim_collapse'
            ],
            left      => [
                'trim_lead'
            ],
            right     => [
                'trim_trail'
            ]
        ],
        [],
        {int_param => '123', left => "abc  ", right => '  def', collapse => "a b c"}
    ]
);

foreach my $info (@infos) {
    validate_ok(@$info);
}

# exception
my @exception_infos = (
    [
        'duplication value1 undefined',
        {
            k1_1 => undef,
            k1_2 => 'a',
        },
        [
            [qw/k1_1 k1_2/] => [
                ['duplication']
            ],
        ],
        qr/\QConstraint 'duplication' needs two keys of data/
    ],
    [
        'duplication value2 undefined',
        {
            k2_1 => 'a',
            k2_2 => undef,
        },
        [
            [qw/k2_1 k2_2/] => [
                ['duplication']
            ]
        ],
        qr/\QConstraint 'duplication' needs two keys of data/
    ],
    [
        'length need parameter',
        {
            k1 => 'a',
        },
        [
            k1 => [
                'length'
            ]
        ],
        qr/\QConstraint 'length' needs one or two arguments/
    ],
    [
        'greater_than target undef',
        {
            k1 => 1
        },
        [
            k1 => [
                'greater_than'
            ]
        ],
        qr/\QConstraint 'greater_than' needs a numeric argument/
    ],
    [
        'greater_than not number',
        {
            k1 => 1
        },
        [
            k1 => [
                {'greater_than' => 'a'}
            ]
        ],
        qr/\QConstraint 'greater_than' needs a numeric argument/
    ],
    [
        'less_than target undef',
        {
            k1 => 1
        },
        [
            k1 => [
                'less_than'
            ]
        ],
        qr/\QConstraint 'less_than' needs a numeric argument/
    ],
    [
        'less_than not number',
        {
            k1 => 1
        },
        [
            k1 => [
                {'less_than' => 'a'}
            ]
        ],
        qr/\QConstraint 'less_than' needs a numeric argument/
    ],
    [
        'equal_to target undef',
        {
            k1 => 1
        },
        [
            k1 => [
                'equal_to'
            ]
        ],
        qr/\QConstraint 'equal_to' needs a numeric argument/
    ],
    [
        'equal_to not number',
        {
            k1 => 1
        },
        [
            k1 => [
                {'equal_to' => 'a'}
            ]
        ],
        qr/\QConstraint 'equal_to' needs a numeric argument/
    ],
    [
        'between target undef',
        {
            k1 => 1
        },
        [
            k1 => [
                {'between' => [undef, 1]}
            ]
        ],
        qr/\QConstraint 'between' needs two numeric arguments/
    ],
    [
        'between target undef or not number1',
        {
            k1 => 1
        },
        [
            k1 => [
                {'between' => ['a', 1]}
            ]
        ],
        qr/\QConstraint 'between' needs two numeric arguments/
    ],
    [
        'between target undef or not number2',
        {
            k1 => 1
        },
        [
            k1 => [
                {'between' => [1, undef]}
            ]
        ],
        qr/\QConstraint 'between' needs two numeric arguments/
    ],
    [
        'between target undef or not number3',
        {
            k1 => 1
        },
        [
            k1 => [
                {'between' => [1, 'a']}
            ]
        ],
        qr/\Qbetween' needs two numeric arguments/
    ],
    [
        'decimal target undef',
        {
            k1 => 1
        },
        [
            k1 => [
                'decimal'
            ]
        ],
        qr/\QConstraint 'decimal' needs one or two numeric arguments/
    ],
    [
        'decimal target not number 1',
        {
            k1 => 1
        },
        [
            k1 => [
                {'decimal' => ['a']}
            ]
        ],
        qr/\QConstraint 'decimal' needs one or two numeric arguments/
    ],
    [
        'DECIMAL target not number 2',
        {
            k1 => 1
        },
        [
            k1 => [
                {'decimal' => [1, 'a']}
            ]
        ],
        qr/\QConstraint 'decimal' needs one or two numeric arguments/
    ],
    
    [
        'datetime_format no exist format',
        {
            k1 => '2000-01-02 03:04:05',
        },
        [
            k1 => [
                'datetime_format'
            ],
        ],
        qr/Constraint 'datetime_format' needs a format argument/
    ],
    [
        'datetime_format no exist format',
        {
            k1 => '2000-01-02 03:04:05',
        },
        [
            k1 => [
                {'datetime_format' => 'NOOOOOOOOOOOOOOOOOOOOOOOOOOO'}
            ],
        ],
        qr/Constraint 'datetime_format': failed to require .*?NOOOOOOOOOOOOOOOOOOOOOOOOOOO/
    ],
    [
        'datetime_strptime no exist format',
        {
            k1 => '03:04:05',
        },
        [
            k1 => [
                'datetime_strptime'
            ],
        ],
        qr/\QConstraint 'datetime_strptime' needs a format argument/
    ],
);

foreach my $exception_info (@exception_infos) {
    validate_exception(@$exception_info)
}

sub validate_ok {
    my ($test_name, $data, $validation_rule, $invalid_keys, $products) = @_;
    my $vc = Validator::Custom::HTMLForm->new;
    my $r = $vc->validate($data, $validation_rule);
    is_deeply([$r->invalid_keys], $invalid_keys, "$test_name invalid_keys");
    if (ref $products eq 'CODE') {
        $products->($r);
    }
    elsif($products) {
        is_deeply($r->products, $products, "$test_name products");
    }
}

sub validate_exception {
    my ($test_name, $data, $validation_rule, $error) = @_;
    my $vc = Validator::Custom::HTMLForm->new;
    eval{$vc->validate($data, $validation_rule)};
    like($@, $error, "$test_name exception");
}

