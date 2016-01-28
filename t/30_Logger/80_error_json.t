use Test::More tests => 3;
use Test::Exception;
use lib 't/lib';

use_ok('Search::Elasticsearch::Error');

eval 'use JSON qw(to_json);';
SKIP: {
    skip 'JSON module not installed',2 if $@;
    ok(my $es_error = Search::Elasticsearch::Error->new(
        'Missing',
        "Foo missing",
        { code => 404 }
    ),'Create test error');
    like(
	to_json({ eserr => $es_error}, { convert_blessed => 1 }),
	qr/Foo missing/,
	'to_json',
    );
}
