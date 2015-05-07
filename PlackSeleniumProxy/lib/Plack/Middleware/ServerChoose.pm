package Plack::Middleware::ServerChoose;
use strict;
use warnings;
use parent qw|Plack::Middleware|;
use DDP;

sub call {
    my ( $self, $env ) = @_;

    #TODO: Validate if server exists with wanted capabilities
    my $res = $self->app->($env);
    Plack::Util::response_cb(
        $res,
        sub {
            my $res = shift;
            return if !$env->{_}->{IS_AUTHORIZED};
            my $req = Plack::Request->new($env);
            if (    #$req->uri->as_string !~ m#/wd/hub/session#
                !$env->{_}->{SESSION_ID}
              )
            {
                warn "[ServerChoose]: Select server";
                $self->choose_server( $res, $env, $req );
            }
            else {
                warn "[ServerChoose]: Select server by session id";
                $self->server_by_session_id( $res, $env, $req );
            }
            return;
        }
    );
}

sub server_by_session_id {
    my $self = shift;
    my $res  = shift;
    my $env  = shift;
    my $req  = shift;

    my $cached_session =
      $env->{_}->{helper}->cache->get( $env->{_}->{SESSION_ID} );
    if ( defined $cached_session ) {
        $env->{_}->{SELENIUM_SERVER_IP}   = $cached_session->{ip};
        $env->{_}->{SELENIUM_SERVER_PORT} = $cached_session->{port};
    }
    else {
        #TODO: die... its a fake session, or expired. Or send a 404 page..
    }
}

sub choose_server {
    my $self = shift;
    my $res  = shift;
    my $env  = shift;
    my $req  = shift;

    my $wanted_capabilities =
      $env->{_}->{helper}->_decode_json( $req->raw_body )
      ->{desiredCapabilities};
    my $server = $env->{_}->{helper}->config->{servers}->{
        lc $wanted_capabilities->{platform} eq 'any'
        ? 'windows'
        : $wanted_capabilities->{platform}
      }->{ lc $wanted_capabilities->{browserName} }
      ->{ $wanted_capabilities->{version} };

    $env->{_}->{SELENIUM_SERVER_IP}           = $server->{ip};
    $env->{_}->{SELENIUM_SERVER_PORT}         = $server->{port};
    $env->{_}->{SELENIUM_SERVER_MACHINE_NAME} = $server->{vboxname};
    $env->{_}->{SELENIUM_SERVER_MACHINE_HOST_IP} = $server->{vm_host_ip};

}

1;
