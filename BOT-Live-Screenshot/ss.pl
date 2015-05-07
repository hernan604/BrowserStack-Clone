use Parallel::ForkManager;
use DDP;
use Redis;
use Time::HiRes;
use IO::Async::Timer::Countdown;
use CHI;
use IO::All;
use Mojo::UserAgent;
my $r  = Redis->new;
my $ua = Mojo::UserAgent->new;

START: {
    warn
"Could not find env var: BROWSERSTACK_DIR_SCREENSHOT.\nConfigure one in env.sh or env_custom.sh"
      and die
      if !$ENV{BROWSERSTACK_DIR_SCREENSHOT};
}

my $chi = CHI->new(
    driver    => 'Redis',
    namespace => 'foo',
    server    => '127.0.0.1:6379',
    debug     => 0
);

my $pm = Parallel::ForkManager->new(30);

while ( my $element = $r->blpop( 'session_start', 99999999 ) ) {
    my $session_id = $element->[1];
    my $pid = $pm->start and next;
    get_ss( $session_id, $pm );
    $pm->finish;    # Terminates the child process
}

sub get_ss {
    print "\nnew session id: $session_id";
    my $session_id = shift;
    my $pm         = shift;
    while ( my $session = $chi->get($session_id) ) {
        $session->{id} = $session_id if !exists $session->{id};
        process($session);
        sleep 2;
    }
}

sub process {
    my $session = shift;
    my $host_url =
      "http://$session->{vm_host_ip}:8002/screenshot/vbox/$session->{vm_name}";
    print $host_url."\n";
    my $tx = $ua->get($host_url);
    io( $ENV{BROWSERSTACK_DIR_SCREENSHOT} . $session->{id} . '.png' )
      ->write( $tx->res->body );
}

