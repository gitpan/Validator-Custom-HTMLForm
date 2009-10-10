use Test::More 'no_plan';

use strict;
use warnings;

use Validator::Custom::HTMLForm;

use lib 't/01-core';
use DateTime::Format::Sample;

my @infos = (
    [
        'NOT_BLANK',
        {
            k1 => undef,
            k2 => 'a',
            k3 => ''
        },
        [
            k1 => [
                'NOT_BLANK'
            ],
            k2 => [
                'NOT_BLANK'
            ],
            k3 => [
                'NOT_BLANK'
            ],        
        ],
        [qw/k1 k3/]
    ],
    [
        'SP',
        {
            k4 => 'a',,
            k5 => 'a ',
        },
        [
            k4 => [
                'SP'
            ],
            k5 => [
                'SP'
            ],
        ],
        [qw/k4/]
    ],
    [
        'SPACE',
        {
            k6 => 'a',,
            k7 => 'a ',
        },
        [
            k6 => [
                'SPACE'
            ],
            k7 => [
                'SPACE'
            ],
        ],
        [qw/k6/]
    ],
    [
        'INT',
        {
            k8  => '19',
            k9  => '-10',
            k10 => 'a',
            k11 => '10.0',
        },
        [
            k8 => [
                'INT'
            ],
            k9 => [
                'INT'
            ],
            k10 => [
                'INT'
            ],
            k11 => [
                'INT'
            ],
        ],
        [qw/k10 k11/]
    ],
    [
        'UINT',
        {
            k12  => '19',
            k13  => '-10',
            k14 => 'a',
            k15 => '10.0',
        },
        [
            k12 => [
                'UINT'
            ],
            k13 => [
                'UINT'
            ],
            k14 => [
                'UINT'
            ],
            k15 => [
                'UINT'
            ],
        ],
        [qw/k13 k14 k15/]
    ],
    [
        'ASCII',
        {
            k16 => '!~',
            k17 => ' ',
            k18 => "\0x7f",
        },
        [
            k16 => [
                'ASCII'
            ],
            k17 => [
                'ASCII'
            ],
            k18 => [
                'ASCII'
            ],
        ],
        [qw/k17 k18/]
    ],
    [
        'LENGTH',
        {
            k19 => '111',
            k20 => '111',
        },
        [
            k19 => [
                {'LENGTH' => [3, 4]},
                {'LENGTH' => [2, 3]},
                {'LENGTH' => [3]},
                {'LENGTH' => 3},
            ],
            k20 => [
                {'LENGTH' => [4, 5]},
            ]
        ],
        [qw/k20/],
    ],
    [
        'DUPLICATION',
        {
            k1_1 => 'a',
            k1_2 => 'a',
            
            k2_1 => 'a',
            k2_2 => 'b'
        },
        [
            {k1 => [qw/k1_1 k1_2/]} => [
                'DUPLICATION'
            ],
            {k2 => [qw/k2_1 k2_2/]} => [
                'DUPLICATION'
            ]
        ],
        [qw/k2/]
    ],
    [
        'REGEX',
        {
            k1 => 'aaa',
            k2 => 'aa',
        },
        [
            k1 => [
                {'REGEX' => "a{3}"}
            ],
            k2 => [
                {'REGEX' => "a{4}"}
            ]
        ],
        [qw/k2/]
    ],
    [
        'EMAIL',
        {
            k1 => 'a@yahoo.com',
            k2 => 'a@b@c',
            k3 => '',
        },
        [
            k1 => [
                'EMAIL'
            ],
            k2 => [
                'EMAIL'
            ],
            k3 => [
                'EMAIL'
            ]
        ],
        [qw/k2 k3/]
    ],
    #[
    #    'EMAIL_MX',
    #    {
    #        k1 => 'a@yahoo.com',
    #        k2 => 'a@b@c',
    #        k3 => '',
    #    },
    #    [
    #        k1 => [
    #            'EMAIL_MX'
    #        ],
    #        k2 => [
    #            'EMAIL_MX'
    #        ],
    #        k3 => [
    #            'EMAIL_MX'
    #        ]
    #    ],
    #    [qw/k2 k3/]
    #],
    [
        'EMAIL_LOOSE',
        {
            k1 => 'a.@yahoo.com',
            k2 => 'a@b@c',
            k3 => '',
        },
        [
            k1 => [
                'EMAIL_LOOSE'
            ],
            k2 => [
                'EMAIL_LOOSE'
            ],
            k3 => [
                'EMAIL_LOOSE'
            ]
        ],
        [qw/k2 k3/]
    ],
    #[
    #    'EMAIL_LOOSE_MX',
    #    {
    #        k1 => 'a.@yahoo.com',
    #        k2 => 'a@b@c',
    #        k3 => '',
    #    },
    #    [
    #        k1 => [
    #            'EMAIL_LOOSE_MX'
    #        ],
    #        k2 => [
    #            'EMAIL_LOOSE_MX'
    #        ],
    #        k3 => [
    #            'EMAIL_LOOSE_MX'
    #        ]
    #    ],
    #    [qw/k2 k3/]
    #],
    [
        'DATE',
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
                'DATE'
            ],
            {k2 => [qw/k2_year k2_month k2_day/]} => [
                'DATE'
            ],
            {k3 => [qw/k3_year k3_month k3_day/]} => [
                {'DATE' => {datetime_class => 'DateTime', time_zone => 'Asia/Tokyo'}}
            ],
            {k4 => [qw/k4_year k4_month k4_day/]} => [
                {'DATE' => {datetime_class => 'Time::Piece'}}
            ],
            {k5 => [qw/k5_year k5_month k5_day/]} => [
                {'DATE' => {datetime_class => 'DateTime'}}
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
        'TIME',
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
                'TIME'
            ],
            {k2 => [qw/k2_hour k2_minute k2_second/]} => [
                'TIME'
            ],
            {k3 => [qw/k3_hour k3_minute k3_second/]} => [
                'TIME'
            ]
        ],
        [qw/k3/],
        {
            k1 => '01:02:03',
            k2 => '00:00:00'
        }
    ],
    [
        'DATETIME',
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
                'DATETIME'
            ],
            {k2 => [qw/k2_year k2_month k2_day k2_hour k2_minute k2_second/ ]} => [
                'DATETIME'
            ],
            {k3 => [qw/k3_year k3_month k3_day k3_hour k3_minute k3_second/ ]} => [
                'DATETIME'
            ],
            {k4 => [qw/k4_year k4_month k4_day k4_hour k4_minute k4_second/ ]} => [
                'DATETIME'],
            {k5 => [qw/k5_year k5_month k5_day k5_hour k5_minute k5_second/ ]} => [
                {'DATETIME' => {datetime_class => 'DateTime', time_zone => 'Asia/Tokyo'}}
            ],
            {k6 => [qw/k6_year k6_month k6_day k6_hour k6_minute k6_second/ ]} => [
                {'DATETIME' => {datetime_class => 'Time::Piece'}}
            ],
            {k7 => [qw/k5_year k7_month k7_day k7_hour k7_minute k7_second/ ]} => [
                {'DATETIME' => {datetime_class => 'DateTime'}}
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
        'HTTP_URL',
        {
            k1 => 'http://www.lost-season.jp/mt/',
            k2 => 'iii',
        },
        [
            k1 => [
                'HTTP_URL'
            ],
            k2 => [
                'HTTP_URL'
            ]
        ],
        [qw/k2/]
    ],
    [
        'SELECTED_AT_LEAST',
        {
            k1 => 1,
            k2 =>[1],
            k3 => [1, 2],
            k4 => [],
            k5 => [1,2]
        },
        [
            k1 => [
                {SELECTED_AT_LEAST => 1}
            ],
            k2 => [
                {SELECTED_AT_LEAST => 1}
            ],
            k3 => [
                {SELECTED_AT_LEAST => 2}
            ],
            k4 => [
                'SELECTED_AT_LEAST'
            ],
            k5 => [
                {'SELECTED_AT_LEAST' => 3}
            ]
        ],
        [qw/k5/]
    ],
    [
        'GREATER_THAN',
        {
            k1 => 5,
            k2 => 5,
            k3 => 'a',
        },
        [
            k1 => [
                {'GREATER_THAN' => 5}
            ],
            k2 => [
                {'GREATER_THAN' => 4}
            ],
            k3 => [
                {'GREATER_THAN' => 1}
            ]
        ],
        [qw/k1 k3/]
    ],
    [
        'LESS_THAN',
        {
            k1 => 5,
            k2 => 5,
            k3 => 'a',
        },
        [
            k1 => [
                {'LESS_THAN' => 5}
            ],
            k2 => [
                {'LESS_THAN' => 6}
            ],
            k3 => [
                {'LESS_THAN' => 1}
            ]
        ],
        [qw/k1 k3/]
    ],
    [
        'EQUAL_TO',
        {
            k1 => 5,
            k2 => 5,
            k3 => 'a',
        },
        [
            k1 => [
                {'EQUAL_TO' => 5}
            ],
            k2 => [
                {'EQUAL_TO' => 4}
            ],
            k3 => [
                {'EQUAL_TO' => 1}
            ]
        ],
        [qw/k2 k3/]
    ],
    [
        'BETWEEN',
        {
            k1 => 5,
            k2 => 5,
            k3 => 5,
            k4 => 5,
            k5 => 'a',
        },
        [
            k1 => [
                {'BETWEEN' => [5, 6]}
            ],
            k2 => [
                {'BETWEEN' => [4, 5]}
            ],
            k3 => [
                {'BETWEEN' => [6, 7]}
            ],
            k4 => [
                {'BETWEEN' => [5, 5]}
            ],
            k5 => [
                {'BETWEEN' => [5, 5]}
            ]
        ],
        [qw/k3 k5/]
    ],
    [
        'DECIMAL',
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
                {'DECIMAL' => [2,3]}
            ],
            k2 => [
                {'DECIMAL' => [1,3]}
            ],
            k3 => [
                {'DECIMAL' => [2,2]}
            ],
            k4 => [
                {'DECIMAL' => [2]}
            ],
            k5 => [
                {'DECIMAL' => 2}
            ],
            k6 => [
                {'DECIMAL' => 2}
            ]
        ],
        [qw/k2 k3 k5 k6/]
    ],
    [
        'IN_ARRAY',
        {
            k1 => 'a',
            k2 => 'a',
            k3 => undef
        },
        [
            k1 => [
                {'IN_ARRAY' => [qw/a b/]}
            ],
            k2 => [
                {'IN_ARRAY' => [qw/b c/]}
            ],
            k3 => [
                {'IN_ARRAY' => [qw/b c/]}
            ]
        ],
        [qw/k2 k3/]
    ],
    [
        'DATETIME_FORMAT' => {
            k1 => '2000-01-02 03:04:05',
            k2 => '2000-01-02 03:04:05',
            k3 => '2000-01-02 03:04:05',
            k4 => '2000-01-02 03:04:05',
            k5 => '2000-01-01 40:01:01',
        },
        [
            k1 => [
                {'DATETIME_FORMAT' => 'Sample'}
            ],
            k2 => [
                {'DATETIME_FORMAT' => ['Sample']}
            ],
            k3 => [
                {'DATETIME_FORMAT' => ['Sample', {time_zone => 'Asia/Tokyo'}]}
            ],
            k4 => [
                {'DATETIME_FORMAT' => DateTime::Format::Sample->new}
            ],
            k5 => [
                {'DATETIME_FORMAT' => 'Sample'}
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
        'DATETIME_FORMAT' => {
            k1 => '01:02:03',
            k2 => '01:02:03',
            k3 => '01:02:03',
            k4 => '25:00:00',
        },        
        [
            k1 => [
                {'DATETIME_STRPTIME' => '%T'}
            ],
            k2 => [
                {'DATETIME_STRPTIME' => ['%T']}
            ],
            k3 => [
                {'DATETIME_STRPTIME' => ['%T', {time_zone => 'Asia/Tokyo'}]}
            ],
            k4 => [
                {'DATETIME_STRPTIME' => '%T'}
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
        'TRIM',
        {
            int_param => ' 123 ',
            collapse  => "  \n a \r\n b\nc  \t",
            left      => '  abc  ',
            right     => '  def  '
        },
        [
            int_param => [
                'TRIM'
            ],
            collapse  => [
                'TRIM_COLLAPSE'
            ],
            left      => [
                'TRIM_LEAD'
            ],
            right     => [
                'TRIM_TRAIL'
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
        'DUPLICATION value1 undefined',
        {
            k1_1 => undef,
            k1_2 => 'a',
        },
        [
            [qw/k1_1 k1_2/] => [
                ['DUPLICATION']
            ],
        ],
        qr/\Qvalidation "DUPLICATION" needs two keys of data./
    ],
    [
        'DUPLICATION value2 undefined',
        {
            k2_1 => 'a',
            k2_2 => undef,
        },
        [
            [qw/k2_1 k2_2/] => [
                ['DUPLICATION']
            ]
        ],
        qr/\Qvalidation "DUPLICATION" needs two keys of data./
    ],
    [
        'LENGTH need parameter',
        {
            k1 => 'a',
        },
        [
            k1 => [
                'LENGTH'
            ]
        ],
        qr/\Qvalidation "LENGTH" needs one or two arguments./
    ],
    [
        'GREATER_THAN target undef',
        {
            k1 => 1
        },
        [
            k1 => [
                'GREATER_THAN'
            ]
        ],
        qr/\QValidation GREATER_THAN needs a numeric argument./
    ],
    [
        'GREATER_THAN not number',
        {
            k1 => 1
        },
        [
            k1 => [
                {'GREATER_THAN' => 'a'}
            ]
        ],
        qr/\QValidation GREATER_THAN needs a numeric argument./
    ],
    [
        'LESS_THAN target undef',
        {
            k1 => 1
        },
        [
            k1 => [
                'LESS_THAN'
            ]
        ],
        qr/\QValidation LESS_THAN needs a numeric argument./
    ],
    [
        'LESS_THAN not number',
        {
            k1 => 1
        },
        [
            k1 => [
                {'LESS_THAN' => 'a'}
            ]
        ],
        qr/\QValidation LESS_THAN needs a numeric argument./
    ],
    [
        'EQUAL_TO target undef',
        {
            k1 => 1
        },
        [
            k1 => [
                'EQUAL_TO'
            ]
        ],
        qr/\QValidation EQUAL_TO needs a numeric argument./
    ],
    [
        'EQUAL_TO not number',
        {
            k1 => 1
        },
        [
            k1 => [
                {'EQUAL_TO' => 'a'}
            ]
        ],
        qr/\QValidation EQUAL_TO needs a numeric argument./
    ],
    [
        'BETWEEN target undef',
        {
            k1 => 1
        },
        [
            k1 => [
                {'BETWEEN' => [undef, 1]}
            ]
        ],
        qr/\QValidation BETWEEN needs two numeric arguments./
    ],
    [
        'BETWEEN target undef or not number1',
        {
            k1 => 1
        },
        [
            k1 => [
                {'BETWEEN' => ['a', 1]}
            ]
        ],
        qr/\QValidation BETWEEN needs two numeric arguments./
    ],
    [
        'BETWEEN target undef or not number2',
        {
            k1 => 1
        },
        [
            k1 => [
                {'BETWEEN' => [1, undef]}
            ]
        ],
        qr/\QValidation BETWEEN needs two numeric arguments./
    ],
    [
        'BETWEEN target undef or not number3',
        {
            k1 => 1
        },
        [
            k1 => [
                {'BETWEEN' => [1, 'a']}
            ]
        ],
        qr/\QValidation BETWEEN needs two numeric arguments./
    ],
    [
        'DECIMAL target undef',
        {
            k1 => 1
        },
        [
            k1 => [
                'DECIMAL'
            ]
        ],
        qr/\QValidation DECIMAL needs one or two numeric arguments./
    ],
    [
        'DECIMAL target not number 1',
        {
            k1 => 1
        },
        [
            k1 => [
                {'DECIMAL' => ['a']}
            ]
        ],
        qr/\QValidation DECIMAL needs one or two numeric arguments./
    ],
    [
        'DECIMAL target not number 2',
        {
            k1 => 1
        },
        [
            k1 => [
                {'DECIMAL' => [1, 'a']}
            ]
        ],
        qr/\QValidation DECIMAL needs one or two numeric arguments./
    ],
    
    [
        'DATETIME_FORMAT no exist format',
        {
            k1 => '2000-01-02 03:04:05',
        },
        [
            k1 => [
                'DATETIME_FORMAT'
            ],
        ],
        qr/Validation DATETIME_FORMAT needs a format argument/
    ],
    [
        'DATETIME_FORMAT no exist format',
        {
            k1 => '2000-01-02 03:04:05',
        },
        [
            k1 => [
                {'DATETIME_FORMAT' => 'NOOOOOOOOOOOOOOOOOOOOOOOOOOO'}
            ],
        ],
        qr/Validation DATETIME_FORMAT: failed to require .*?NOOOOOOOOOOOOOOOOOOOOOOOOOOO/
    ],
    [
        'DATETIME_STRPTIME no exist format',
        {
            k1 => '03:04:05',
        },
        [
            k1 => [
                'DATETIME_STRPTIME'
            ],
        ],
        qr/\QValidation DATETIME_STRPTIME needs a format argument/
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
        is_deeply({$r->products}, $products, "$test_name products");
    }
}

sub validate_exception {
    my ($test_name, $data, $validation_rule, $error) = @_;
    my $vc = Validator::Custom::HTMLForm->new;
    eval{$vc->validate($data, $validation_rule)};
    like($@, $error, "$test_name exception");
}

