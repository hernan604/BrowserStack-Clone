package SeleniumProxy::Middleware::Screenshot;
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
            return
              if $req->uri->as_string !~
              m#/wd/hub/session/(?<session_id>[^/]+)/(.+)#g
              ;    #return if not has session_id
            my $req = Plack::Request->new($env);
            warn "=> START Middleware::Screenshot";
            my $uri = $req->uri->clone;
            $uri->host( $env->{_}->{SELENIUM_SERVER_IP} );
            $uri->port( $env->{_}->{SELENIUM_SERVER_PORT} );

            $req->headers->remove_header('Host');
            my $method = lc $req->method;
            warn "=>>>> UA REQ SS " . $uri->as_string;
            
            my $screenshot_url = join "", (
                "http://",$env->{_}->{SELENIUM_SERVER_IP},":",$env->{_}->{SELENIUM_SERVER_PORT},"/wd/hub/session/",$+{session_id},"/screenshot");

            my $start  = $env->{_}->{helper}->_timeofday;
            my $ua_res = $env->{_}->{helper}->ua->$method(
                $uri->as_string,
                {
                    headers => $req->headers,
                    content => $req->content,
                }
            );
            my $finish = $env->{_}->{helper}->_timeofday;
            my $elapsed = $env->{_}->{helper}->_tv_interval( $start, $finish );

            my $image = $ua_res->{content};
p $image;
warn "==> SAVE SCREENSHOT IMAGE";
               #$env->{_}->{helper}
               #  ->db->selenium_log_create( $env->{_}->{SESSION_ID},
               #    $action, $env->{_}->{SELENIUM_REQUEST_ELAPSED} );

        }
    );
}

1;
