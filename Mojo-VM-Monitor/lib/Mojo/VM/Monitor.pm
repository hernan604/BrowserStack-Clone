package Mojo::VM::Monitor;
use base 'Mojolicious';

sub startup {
    my $self = shift;
    my $r = $self->routes;
    $r->namespaces(['Mojo::VM::Monitor::Controller']);
    $r->route('/screenshot/vbox/:machine_name')
        ->to( controller => 'Virtualbox', action => 'screenshot' );
}

1;
