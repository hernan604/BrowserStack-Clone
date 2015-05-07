package Plack::Middleware::LogAction;
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
            warn '[LogAction] Start';
            my $res = shift;
            my $req = Plack::Request->new($env);
            if ( $env->{_}->{SESSION_ID} ) {

                #log action
                my ( $session_id, $action ) = $req->uri->as_string =~
                  m#session/(?<session_id>[^/]+)/(?<action>.*)#;
                if ( !$action ) { $action = 'quit' }
                $env->{_}->{helper}
                  ->db->selenium_log_create( $env->{_}->{SESSION_ID},
                    $action, $env->{_}->{SELENIUM_REQUEST_ELAPSED} );
            }
        }
    );
}

1;
