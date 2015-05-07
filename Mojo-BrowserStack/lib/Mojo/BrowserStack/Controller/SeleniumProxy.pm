package Mojo::BrowserStack::Controller::SeleniumProxy;
use Mojo::Base 'Mojolicious::Controller';
use Time::HiRes qw(gettimeofday tv_interval);

=head2 forward

This is the selenium proxy. The content is always json. 
Selenium::Remote::Drivers will connect on this endpoint which will then forward
to selenium endpoint. Then it will receive a response, fix some headers and
build the final response for the user.

=cut 

sub forward {
    my $self = shift;

#   $self->basic_auth(
#       realm => sub {
#           #TODO: Validate usage: User could be blocked if exceed hours
#           $self->session( username => $_[0] );
#           $self->session( password => $_[1] );
#           my $user = $self->db->user_find($_[0], $_[1]);
#           return 0 if ! exists $user->{ id };
#           $self->session( user_id => $user->{ id } );
#       }
#   );

    $self->respond_to( json => sub {
        my $self = shift;
        $self->render_later;

        $self->before_selenium_request;
        my $action_start = [gettimeofday];
        return $self->render_default_status
            if $self->req->url eq "/wd/hub/status";

        my $req = {
            method  => lc $self->tx->req->method,
            uri     => 'http:'.$self->req->url->to_string,
            headers => $self->tx->req->headers->to_hash,
            content => $self->tx->req->json,
        };

        my $method = $req->{ method };
        #make the request to selenium
       #my $ua = $self->ua->$method( 
       #    $req->{ uri }   => $req->{ headers }, 
       #    json            => $req->{content} 
       #);
        $self->ua->$method(
            $req->{ uri }   => $req->{ headers }, 
            json            => $req->{content} 
            
            => sub {
 use DDP;
       p $req->{ headers };
#               p @_;
                warn "^^ ARGS ";
                my $ua = shift;
                my $tx = shift;
                warn 'REQUEST DONE..';
                my $action_finish = [gettimeofday];

                $self->after_selenium_request( {
                    req             => $tx->req, 
                    res             => $tx->res,
                    action_start    => $action_start,
                    action_finish   => $action_finish,
                    action_elapsed  => ($action_finish - $action_start),
                } );
#               p $tx->req;
                warn "====> REQUEST URL: ".$tx->req->url."";
#               warn $tx->req->url."";
#               p $tx->res;
                $self->res->headers->from_hash( $tx->res->headers->to_hash );
                $self->render( json => $tx->res->json );

            }
        );
    } );
}

sub render_default_status {
    my $self = shift;
    $self->render( json => {
        "state" => "unhandled error",
        "sessionId" => undef,
        "hCode" => 21661319,
        "value" => {
            "localizedMessage" => undef,
            "cause" => undef,
            "stackTrace" => [
                (undef) x 22
            ],
            "suppressed" => [],
            "message" => undef,
            "hCode" => 31193878,
            "class" => "java.lang.NullPointerException"
        },
        "class" => "org.openqa.selenium.remote.Response",
        "status" => 13
    } );
}

sub before_selenium_request {
    my $self = shift;
    foreach my $plugin ( @{ $self->selenium_plugin->{before_selenium_request} } ) {
        $plugin->process( $self, { req => $self->req } );
    }
}

sub after_selenium_request {
    my $self = shift;
    my $args = shift;
    foreach my $plugin ( @{ $self->selenium_plugin->{after_selenium_request} } ) {
        $plugin->process( $self, $args );
    }
}

1;
