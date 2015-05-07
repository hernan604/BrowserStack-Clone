package Mojo::BrowserStack::Controller::Admin;
use base 'Mojolicious::Controller';

sub index {
    my $self = shift;
    $self->respond_to( html => sub {
        my $self = shift;
        $self->render( 'v1/admin/index' );
    } );
}

1;
