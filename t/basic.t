use strict;
use warnings;
use Test::More tests => 3;

use Devel::REPL;
use Test::Exception;

my $r = Devel::REPL->new;
ok $r;

my $out;
is $r->run_once('2 + 2'), 4, 'output callback called';
like $r->run_once('die "OH NOES"'), qr/^Runtime error/, 'got error msg';

