package Plack::Middleware::Authorization;
use strict;
use warnings;
use parent qw|Plack::Middleware|;
use MIME::Base64;
use DDP;

# sets env->{IS_AUTHORIZED}
# Checks Basic Authorization if use does not have a SessionID.
# if ! session_id
#       check basic authorization
#       if ! valid_credentials
#            return 401 unauthorized
#       else
#            make selenium request and get session_id
#           save the session_id for this user in the database
#       end

sub is_authorized {
    my $self = shift;
    my $env  = shift;
    my $user = $env->{_}->{helper}->db->user_find( shift, shift );
    if ( $user && exists $user->{id} ) {
        $env->{_}->{db_user} = $user;
        return 1;
    }
    return 0;
}

sub call {
    my ( $self, $env ) = @_;
    my $res = $self->app->($env);
    Plack::Util::response_cb(
        $res,
        sub {
            my $res = shift;
            warn "=> START Middleware::Authorization";
            my $req = Plack::Request->new($env);
            p $req->raw_body;
            warn "^^ REQ";

            if ( $self->url_has_session_id( $req, $env ) ) {
                if ( !$self->is_session_still_valid($env) ) {
                    $env->{_}->{IS_AUTHORIZED} = 0;
                    $self->unauthorized($res);
                }
                else {
                    $env->{_}->{IS_AUTHORIZED} = 1;
                }
            }
            elsif ( !$self->url_has_session_id( $req, $env )
                && $req->headers->header('Authorization')
                && $req->uri->as_string !~ m#/wd/hub/status#g )
            {
                my $authb64 = $req->headers->header('Authorization');

                #check the user credentials against the database
                $authb64 =~ s|^Basic (.+)|$1|;
                my ( $user, $pass ) = split /:/,
                  ( MIME::Base64::decode($authb64) || ":" ), 2;
                $pass = '' unless defined $pass;
                $env->{_}->{USER} = $user;
                $env->{_}->{PASS} = $pass;
                if ( $self->is_authorized( $env, $user, $pass ) ) {
                    $env->{_}->{IS_AUTHORIZED} = 1;
                }
                else {
                    $env->{_}->{IS_AUTHORIZED} = 0;
                    $self->unauthorized($res);
                }
            }
            elsif ( !$self->url_has_session_id( $req, $env )
                && $req->uri->as_string =~ m#/wd/hub/status#g )
            {
                $env->{_}->{IS_AUTHORIZED} = 0;
                $self->initial_response($res);
            }
            else {
                $self->unauthorized($res);
            }
            return;
        }
    );
}

sub initial_response {
    my $self = shift;
    my $res  = shift;
    my $body =
'{"state":"success","sessionId":null,"hCode":27719055,"value":{"build":{"version":"2.45.0","revision":"5017cb8","time":"2015-02-26 23:59:50"},"os":{"name":"Windows 7","arch":"x86","version":"6.1"},"java":{"version":"1.8.0_40"}},"class":"org.openqa.selenium.remote.Response","status":0}';
    @$res = (
        200,
        [
            'Content-Length' => length $body,
            "Date"           => "Mon, 27 Apr 2015 21:30:04 GMT",
            "Server"         => "Jetty/5.1.x (Windows 7/6.1 x86 java/1.8.0_40",
            "Expires"        => "Thu, 01 Jan 1970 00:00:00 GMT",
            "Connection"     => "close",
            "Cache-Control"  => "no-cache",
            "Content-Type"   => "application/json; charset=utf-8",
        ],
        [$body],
    );
}

sub url_has_session_id {
    my $self = shift;
    my $req  = shift;
    my $env  = shift;
    $env->{_}->{SESSION_ID} = $+{session_id}
      and return 1
      if $req->uri->as_string =~ m#/session/(?<session_id>[^/]+)#g;
}

sub is_session_still_valid {

#check if there is a session_id in the url. AND session_id still not 'finished' in db
    my $self = shift;
    my $env  = shift;

    #$env->{SESSION_ID};
    return 1;
}

sub unauthorized {
    my $self = shift;
    my $res  = shift;
    my $body = 'Authorization required';
    @$res = (
        401,
        [
            'Content-Type'   => 'text/plain',
            'Content-Length' => length $body,
        ],
        [$body],
    );
}

1;
