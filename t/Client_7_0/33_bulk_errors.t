# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

use Test::More;
use Test::Deep;
use Test::Exception;

use strict;
use warnings;
use lib 't/lib';
use Log::Any::Adapter;

$ENV{ES_VERSION} = '7_0';
my $es = do "es_sync.pl" or die( $@ || $! );
my $TRUE = $es->transport->serializer->decode('{"true":true}')->{true};

$es->indices->delete( index => '_all' );

my @Std = (
    { id => 1, source => { count => 1 } },
    { id => 1, source => { count => 'foo' } },
);

my ( $b, $success_count, $error_count, $custom_count, $conflict_count );

## Default error handling
$b = bulk( { index => 'test' }, @Std );
test_flush( "Default", 0, 1, 0, 0 );

## Custom error handling
$b = bulk(
    {   index    => 'test',
        on_error => sub { $custom_count++ }
    },
    @Std
);
test_flush( "Custom error", 0, 0, 1, 0 );

# Disable both
$b = bulk(
    {   index       => 'test',
        on_conflict => undef,
        on_error    => undef
    },
    @Std
);

test_flush( "Both undef", 0, 0, 0, 0 );

# Success
$b = bulk(
    {   index      => 'test',
        on_success => sub { $success_count++ },
    },
    @Std
);

test_flush( "Success", 1, 1, 0, 0 );

# cbs have correct params
$b = bulk(
    {   index      => 'test',
        on_success => test_params(
            'on_success',
            {   _index        => 'test',
                _id           => 1,
                _version      => 1,
                status        => 201,
                created       => $TRUE,
                result        => 'created',
                _shards       => { successful => 1, total => 2, failed => 0 },
                _primary_term => 1,
                _seq_no => 0
            },
            0
        ),
        on_error => test_params(
            'on_error',
            {   _index => 'test',
                _id    => 1,
                error  => any(
                    re('MapperParsingException'),
                    superhashof( { type => 'mapper_parsing_exception' } )
                ),
                status => 400,
            },
            1
        ),
        on_conflict => test_params(
            'on_conflict',
            {   _index => 'test',
                _id    => 1,
                error  => any(
                    re('version conflict'),
                    superhashof(
                        { type => 'version_conflict_engine_exception' }
                    )
                ),
                status => 409,
            },
            2,
            1
        ),
    },
    @Std
);
$b->flush;

done_testing;

$es->indices->delete( index => 'test' );

#===================================
sub bulk {
#===================================
    my $params = shift;
    my $b      = $es->bulk_helper($params);
    $es->indices->delete( index => 'test', ignore => 404 );
    $es->indices->create( index => 'test' );
    $es->cluster->health( wait_for_status => 'yellow' );
    $b->index(@_);
    return $b;
}

#===================================
sub test_flush {
#===================================
    my ( $title, $success, $default, $custom, $conflict ) = @_;
    $success_count = $custom_count = $error_count = $conflict_count = 0;
    {
        local $SIG{__WARN__} = sub { $error_count++ };
        $b->flush;
    }
    is $success_count,  $success,  "$title - success";
    is $error_count,    $default,  "$title - default";
    is $custom_count,   $custom,   "$title - custom";
    is $conflict_count, $conflict, "$title - conflict";

}

#===================================
sub test_params {
#===================================
    my ( $type, $result, $j, $version ) = @_;

    return sub {
        is $_[0], 'index', "$type - action";
        is $_[2], $j,       "$type - array index";
        is $_[3], $version, "$type - version";
    };
}
