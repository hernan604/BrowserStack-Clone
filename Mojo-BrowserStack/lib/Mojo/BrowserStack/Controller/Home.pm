package Mojo::BrowserStack::Controller::Home;
use Mojo::Base 'Mojolicious::Controller';

sub index {
    my $self = shift;
    $self->render( 'v1/index' );
}

1;
