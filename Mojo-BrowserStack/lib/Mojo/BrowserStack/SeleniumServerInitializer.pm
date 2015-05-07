package Mojo::BrowserStack::SeleniumServerInitializer;
use Moo;
use MIME::Base64;
#ABSTRACT: Define the server ip addresses for each browser+version

has app => ( is => 'rw' );
has r   => ( is => 'rw' );  #request or response, depends if its before or after request.
has browsers    => ( is => 'lazy', default => sub {
    my $self = shift;
    $self->app->browser;
} );

sub process {
    my $self = shift;
    $self->app( shift );
    my $args = shift;
    $self->r( $args->{req} ); 
    return if ! $self->validate;

    my $wanted_browser = $self->r->json;

    my $wanted = {
        browser => $wanted_browser->{desiredCapabilities}->{browserName},
        version => $wanted_browser->{desiredCapabilities}->{version},
    };
    use DDP;
    p $wanted;
    my $server = $self->browsers->{ $wanted->{browser} }->{ $wanted->{version} };
    $self->r->url->host( $server->{ip} );
    $self->r->url->port( $server->{port} );
}

sub validate {
    my $self = shift;
    return 1 if 
        $self->r->url eq '/wd/hub/session';
    return 0;
}

1;
