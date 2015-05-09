package SeleniumProxy::Middleware::SeleniumRequest;
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
            return if !$env->{_}->{IS_AUTHORIZED};
            warn "=> START Middleware::SeleniumRequest";
            my $req = Plack::Request->new($env);
            my $uri = $req->uri->clone;
            $uri->host( $env->{_}->{SELENIUM_SERVER_IP} );
            $uri->port( $env->{_}->{SELENIUM_SERVER_PORT} );

            $req->headers->remove_header('Host');
            my $method = lc $req->method;
            warn "=>>>> UA REQ " . $uri->as_string;
            $env->{_}->{SELENIUM_REQUEST_START} =
              $env->{_}->{helper}->_timeofday;

            my $content =$self->remove_platform_definition( $req, $env ) if $req->content =~ m#platform#g;

            my $ua_res = $env->{_}->{helper}->ua->$method(
                $uri->as_string,
                {
                    headers => $req->headers,
                    content => $content || $req->content,
                }
            );

            $env->{_}->{SELENIUM_REQUEST_FINISH} =
              $env->{_}->{helper}->_timeofday;
            $env->{_}->{SELENIUM_REQUEST_ELAPSED} =
              $env->{_}->{helper}->_tv_interval(
                $env->{_}->{SELENIUM_REQUEST_START},
                $env->{_}->{SELENIUM_REQUEST_FINISH}
              );

            $res->[0] = $ua_res->{status};
            $res->[1] = [ %{ $ua_res->{headers} } ];
            $res->[2] = [ $ua_res->{content} ];
            return;
        }
    );
}

sub remove_platform_definition {
    #the server was already chosen based on wanted platform. Its not necessary to pass on this info. If the information is omitted it will be "ANY" and its no problem for the destiny server.
    my $self = shift;
    my $req = shift;
    my $env = shift;
    my $content = $env->{_}->{helper}->_decode_json( $req->content );

    if ( exists $content->{desiredCapabilities} 
    and exists $content->{desiredCapabilities}->{ platform } ) {
        delete $content->{desiredCapabilities}->{ platform };
        $content = $env->{_}->{helper}->_encode_json( $content );
        $req->headers->remove_header('content-length');
        return $content;
    }
}

1;
