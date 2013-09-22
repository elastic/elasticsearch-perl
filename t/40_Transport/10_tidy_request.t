use Test::More;
use Test::Deep;
use Elasticsearch;

isa_ok my $t = Elasticsearch->new->transport, 'Elasticsearch::Transport';
test_tidy( 'Empty', {}, {} );
test_tidy( 'Method', { method => 'POST' }, { method => 'POST' } );
test_tidy( 'Path',   { path   => '/foo' }, { path   => '/foo' } );
test_tidy( 'QS', { qs => { foo => 'bar' } }, { qs => { foo => 'bar' } } );

test_tidy(
    'Body - Str',
    { body => 'foo' },
    { body => 'foo', data => 'foo', serialize => 'std' }
);

test_tidy(
    'Body - Hash',
    { body => { foo => 'bar' } },
    {   body      => { foo => 'bar' },
        data      => '{"foo":"bar"}',
        serialize => 'std'
    }
);

test_tidy(
    'Body - Array',
    { body => [ { foo => 'bar' } ] },
    {   body      => [ { foo => 'bar' } ],
        data      => '[{"foo":"bar"}]',
        serialize => 'std'
    }
);

test_tidy(
    'Body - Bulk',
    { body => [ { foo => 'bar' } ], serialize => 'bulk' },
    {   body      => [ { foo => 'bar' } ],
        data      => qq({"foo":"bar"}\n),
        serialize => 'bulk'
    }
);

#===================================
sub test_tidy {
#===================================
    my ( $title, $params, $test ) = @_;
    $test = {
        method => 'GET',
        path   => '/',
        qs     => {},
        ignore => [],
        %$test
    };
    cmp_deeply $t->tidy_request($params), $test, $title;
}

done_testing;
