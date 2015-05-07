{

    package MyHelper;
    use Moo;
    use JSON::XS;
    use HTTP::Tiny;
    use Time::HiRes;
    use IO::All;
    use JSON::XS;
    use Mojo::BrowserStack::DB;
    use CHI;
    use Redis;

    has ua => (
        is      => 'rw',
        default => sub {
            HTTP::Tiny->new;
        }
    );

    has db => (
        is      => 'rw',
        default => sub {
            Mojo::BrowserStack::DB->new(
                dsn                 => $ENV{BROWSERSTACK_DSN},
                filepath_migrations => $ENV{BROWSERSTACK_MIGRATIONS},
            );
        }
    );

    has config => (
        is      => 'rw',
        default => sub {

            print '[ERROR] Config file not found\n' and die
              if !-e $ENV{BROWSERSTACK_CONFIG};
            eval io( $ENV{BROWSERSTACK_CONFIG} )->slurp;
        }
    );

    has cache => (
        is => 'rw',
        default => sub {
            CHI->new(
                driver => 'Redis',
                namespace => 'foo',
                server => '127.0.0.1:6379',
                debug => 0
            );
        }
    );

    has redis => ( is => 'rw', default => sub {
        Redis->new
    } );

    sub _decode_json {
        my $self = shift;
        JSON::XS::decode_json shift;
    }

    sub _encode_json {
        my $self = shift;
        JSON::XS::encode_json shift;
    }

    sub _timeofday {
        my $self = shift;
        [Time::HiRes::gettimeofday];
    }

    sub _tv_interval {
        my $self = shift;
        Time::HiRes::tv_interval( shift, shift );
    }

    sub _config {
        my $self = shift;
    }
}

use strict;
use warnings;
use DDP;
use Plack::Request;
use Plack::Response;
use Plack::Builder;

my $helper   = MyHelper->new;
my $sessions = {};

my $app = sub {
    my $env = shift;
    $env->{_}->{helper}   = $helper;
    $env->{_}->{sessions} = $sessions;
    my $req = Plack::Request->new($env);
    my $res = Plack::Response->new(200);
    $res->finalize;
};

builder {
    #LAST (these are executed last)
    enable "+Plack::Middleware::Last";
#   enable "+Plack::Middleware::Screenshot";
    enable "+Plack::Middleware::ServerSessionId";
    enable "+Plack::Middleware::LogAction";
    enable "+Plack::Middleware::SeleniumRequest";
    enable "+Plack::Middleware::ServerChoose";
    enable "+Plack::Middleware::Authorization";
    enable "+Plack::Middleware::RequestJsonInflator";
    #FIRST (these are executed first)
    $app;
};

