package SeleniumProxy::Middleware::RequestJsonInflator;
use strict;
use warnings;
use parent qw|Plack::Middleware|;
use DDP;
#ABSTRACT: Gets the $env{session_id} and parse url to discover action. then log in db

sub call {
    my ( $self, $env ) = @_;
    my $res = $self->app->($env);
    Plack::Util::response_cb(
        $res,
        sub {
        my $res = shift;
        my $req = Plack::Request->new($env);
        if ( $req->headers->header('content-type') && 
             $req->headers->header('content-type') =~ m#json# ) {
            $env->{_}->{REQUEST_JSON} = $env->{_}->{helper}->_decode_json( $req->raw_body || "{}" );
        }
    });
}

1;
