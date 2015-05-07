package Mojo::BrowserStack::SeleniumServerIpPortPatcher;
#ABSTRACT: modifies the destiny ip and port with the one associated with session id
use Moo;

has app => ( is => 'rw' );
has req => ( is => 'rw' );  
has res => ( is => 'rw' );  
has session_id => ( is => 'rw' );

sub process {
    my $self = shift;
    $self->app( shift );
    my $args = shift;
    $self->req( $args->{req} ); 
    $self->res( $args->{res} ); 
    return if ! $self->validate;
    my $server_info = $self->app->selenium_session->{ $self->session_id }->{ server };


    use DDP;
    warn $self->session_id;
    warn $self->session_id;
    warn $self->session_id;
    p $server_info;
    p $self->app->selenium_session;
    warn "^^ SERVER INFO";

#p $self->app->selenium_session->{ $self->session_id };

    $self->req->url->host( $server_info->{ host } );
    $self->req->url->port( $server_info->{ port } );
}

sub validate {
    my $self = shift;
    if ( ($self->req->url."") =~ m#^/wd/hub/session/(?<session_id>[^/]+)#g ) {
        $self->session_id( $+{ session_id } );
        warn "====> VALIDO";
        return 1;
    }
    warn "====> NAO VALIDO";
    return 0;
}

1;
