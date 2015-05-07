package Mojo::BrowserStack::Logger;
#ABSTRACT: Logs the user actions
use Moo;
use MIME::Base64;

has app             => ( is => 'rw' );
has req             => ( is => 'rw' );  
has res             => ( is => 'rw' );  
has session_id      => ( is => 'rw' );
has action          => ( is => 'rw' );
has action_start    => ( is => 'rw' );
has action_finish   => ( is => 'rw' );
has action_elapsed  => ( is => 'rw' );

sub process {
    my $self = shift;
    $self->app( shift );
    my $args = shift;
    $self->req( $args->{req} ); 
    $self->res( $args->{res} ); 
    $self->action_start( $args->{ action_start } );
    $self->action_finish( $args->{ action_finish } );
    $self->action_elapsed( $args->{ action_elapsed } );
    return if ! $self->validate;

    $self->app->db->selenium_log_create(
        $self->session_id,
        $self->action,
        $self->action_elapsed,
    );
}

sub validate {
    my $self = shift;
    if ( ($self->req->url."") =~ m#/wd/hub/session/(?<session_id>[^/]+)(?<action>.*)#g ) {
        $self->session_id( $+{ session_id } );
        $self->action( $+{ action } );
        return 1;
    }
    return 0;
}

1;
