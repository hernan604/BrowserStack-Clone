use Selenium::Remote::Driver;
use Test::More;
use DDP;

my $login   = "teste";
my $key     = "teste123";
my $host    = "$login:$key\@127.0.0.1";

my $driver = Selenium::Remote::Driver->new( {
    browser_name        => "firefox",
    remote_server_addr  => $host,
    port                => 5555,
#   port                => 8001,
    version             => 1,
    name                => 'Perl test',
    tags                => ['perl','js'],
} );

for (1..10) {
$driver->get( 'http://www.google.com' );
ok( $driver->get_title eq 'Google' , 'title is correct' );
my $inputElement = $driver->find_element("q", "name");
$inputElement->send_keys("cheese!");
$inputElement->submit();
$driver->set_implicit_wait_timeout(10001);
ok( $driver->find_element("/html/head/title[contains(translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'cheese!')]") , 'encontrou elemento' );
$title = $driver->get_title();
like( $title, qr|cheese|, 'title is correct' );
my $elem = $driver->find_element_by_css("li.g:nth-child(1) h3 a");
like( $elem->get_text, qr/cheese/i, 'texto contem cheese');
}

$driver->quit();

done_testing;

