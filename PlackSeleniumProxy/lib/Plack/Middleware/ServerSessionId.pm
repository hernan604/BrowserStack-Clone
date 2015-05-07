package Plack::Middleware::ServerSessionId;
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
            my $req = Plack::Request->new($env);
# p $req->method;
            return if $req->uri->as_string =~ m#/wd/hub/session/(?<session_id>[^/]+)/(.+)#g; #has session id 
            if ( lc $req->method eq 'delete' ) {
                $self->session_finalize( $env, $req, $res );
            } elsif ( lc $req->method eq 'post' ) {
                my $body = $env->{_}->{helper}->_decode_json( $res->[2]->[0] );
                $env->{_}->{SESSION_ID} = $body->{sessionId};
                $self->create_sesssion( $env, $req, $res );
                
                $env->{_}->{helper}->cache->set(
                    $env->{_}->{SESSION_ID},
                    {
                        ip       => $env->{_}->{SELENIUM_SERVER_IP},
                        port     => $env->{_}->{SELENIUM_SERVER_PORT},
                        vm_name     => $env->{_}->{SELENIUM_SERVER_MACHINE_NAME},
                        vm_host_ip     => $env->{_}->{SELENIUM_SERVER_MACHINE_HOST_IP},
                    },
                    "10 minutes"
                );

#               $env->{_}->{sessions}->{ $env->{_}->{SESSION_ID} } = {
#                   ip   => $env->{_}->{SELENIUM_SERVER_IP},
#                   port => $env->{_}->{SELENIUM_SERVER_PORT},
#               };
            }
        }
    );
}

sub create_sesssion {
    my $self = shift;
    my $env  = shift;
    my $req  = shift;
    my $res  = shift;
    $env->{_}->{helper}->db->selenium_session_create(
        $env->{_}->{SESSION_ID},                                     #session id
        $env->{_}->{db_user}->{id},                                  #id
        'initialized',                                               #status
        $env->{_}->{REQUEST_JSON}->{desiredCapabilities}->{browserName},  #browser
        ( $env->{_}->{REQUEST_JSON}->{desiredCapabilities}->{version} || "ANY" )
        ,                                                            #version
        $env->{_}->{REQUEST_JSON}->{desiredCapabilities}->{platform},     #platform
        $env->{_}->{SELENIUM_SERVER_IP},                             #host
        $env->{_}->{SELENIUM_SERVER_PORT},                           #port
        ($env->{_}->{REQUEST_JSON}->{desiredCapabilities}->{name}||"No name"),#name
        ($env->{_}->{REQUEST_JSON}->{desiredCapabilities}->{tags}
            ?   join ',' , @{ $env->{_}->{REQUEST_JSON}->{desiredCapabilities}->{tags} } 
            :   ''),#tags
        $env->{_}->{SELENIUM_SERVER_MACHINE_NAME},# vm name
        $env->{_}->{SELENIUM_SERVER_MACHINE_HOST_IP},# vm host_ip
    );

    $env->{_}->{helper}->redis->lpush( #for the bots to download screenshot
        $ENV{BROWSERSTACK_QUEUE_SESSION_START},
        $env->{_}->{SESSION_ID});
}

sub session_finalize {
    my $self = shift;
    my $env  = shift;
    my $req  = shift;
    my $res  = shift;
    #TODO: check the user here... any user can finalize any session
    $env->{_}->{helper}->db->selenium_session_finalize( $env->{_}->{SESSION_ID} );
    $env->{_}->{helper}->cache->remove($env->{_}->{SESSION_ID});

}

1;
