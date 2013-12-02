use Test::More;
use Test::Deep;
use Elasticsearch;

my $t = Elasticsearch->new( send_get_body_as => 'GET' )->transport;

test_tidy( 'GET-empty', { path => '/_search' }, {} );
test_tidy(
    'GET-body',
    { path => '/_search', body => { foo => 'bar' } },
    {   body      => { foo => 'bar' },
        data      => '{"foo":"bar"}',
        method    => 'GET',
        mime_type => 'application/json',
        serialize => 'std',
    }
);

$t = Elasticsearch->new( send_get_body_as => 'POST' )->transport;

test_tidy( 'POST-empty', { path => '/_search' }, {} );
test_tidy(
    'POST-eody',
    { path => '/_search', body => { foo => 'bar' } },
    {   body      => { foo => 'bar' },
        data      => '{"foo":"bar"}',
        method    => 'POST',
        mime_type => 'application/json',
        serialize => 'std',
    }
);

$t = Elasticsearch->new( send_get_body_as => 'source' )->transport;

test_tidy( 'source-empty', { path => '/_search' }, {} );
test_tidy(
    'source-body',
    { path => '/_search', body => { foo => 'bar' } },
    {   method    => 'GET',
        qs        => { source => '{"foo":"bar"}' },
        mime_type => 'application/json',
        serialize => 'std',
    }
);

#===================================
sub test_tidy {
#===================================
    my ( $title, $params, $test ) = @_;
    $test = {
        method => 'GET',
        path   => '/_search',
        qs     => {},
        ignore => [],
        %$test
    };
    cmp_deeply $t->tidy_request($params), $test, $title;
}

done_testing;
