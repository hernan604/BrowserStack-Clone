package Plack::Middleware::Last;
use strict;
use warnings;
use parent qw|Plack::Middleware|;
use DDP;

sub call {
    my ( $self, $env ) = @_;
    my $res = $self->app->($env);
    Plack::Util::response_cb(
        $res,
        sub {
            my $res = shift;
           #p $res;
        }
    );
}

1;
