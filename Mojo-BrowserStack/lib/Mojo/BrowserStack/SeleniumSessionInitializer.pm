package Mojo::BrowserStack::SeleniumSessionInitializer;
#ABSTRACT: Associates sessionID with server ip and port. This is used to build the seleniums server url
use Moo;

has app => ( is => 'rw' );
has req => ( is => 'rw' );  
has res => ( is => 'rw' );  

sub process {
    my $self = shift;
    $self->app( shift );
    my $args = shift;
    $self->req( $args->{req} ); 
    $self->res( $args->{res} ); 
    warn 'RES =-=-=-=> ' . $self->req->url;
    return if ! $self->validate;
#   my $session = $self->res->json->{value}->{'webdriver.remote.sessionid'};

    my $session = $self->res->json->{sessionId};
#   use DDP;
#   p $self->res->json;
#   warn "^^ RESPONSE ^^ ";
#   warn "^^ RESPONSE ^^ ";
#   warn "^^ RESPONSE ^^ ";
#   warn "^^ RESPONSE ^^ ";

    $self->app->selenium_session->{ $session } = {
        server => {
            host => $self->req->url->host,
            port => $self->req->url->port,
        }
    };
use DDP; p $self->app->selenium_session;
warn "=============> SETOU SELENIUM _SESSION ^^^^^^^^^^ ";

#   $self->app->db->selenium_session_create(
#       $session, 
#       $self->app->session('user_id'), 
#       'initialized',
#       $self->req->json->{browserName},
#       $self->req->json->{version},
#       $self->req->json->{platform},
#       $self->req->url->host,
#       $self->req->url->port,
#   );

}

sub validate {
    my $self = shift;
    return 1 if 
        $self->req->url =~ m#/wd/hub/session$#
        and $self->res->json 
        and exists $self->res->json->{sessionId} and defined $self->res->json->{sessionId}
#       and $self->res->json->{value}->{'webdriver.remote.sessionid'}
        and $self->req->url->host
        and $self->req->url->port
        ;
    return 0;
}

1;
