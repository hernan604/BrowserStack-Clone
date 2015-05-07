use strict;
use warnings;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Mojo::BrowserStack');
$t->get_ok('/')->content_like(qr|wser|);

done_testing;

