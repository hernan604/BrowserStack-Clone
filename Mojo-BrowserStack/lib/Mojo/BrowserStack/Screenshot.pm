package Mojo::BrowserStack::Screenshot;
#ABSTRACT: Takes a screen shot after browser
use Moo;
use MIME::Base64;

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

    my $screenshot_url = join "", (
        "http://",
        $server_info->{host},
        ":",
        $server_info->{port},
        "/wd/hub/session/",
        $self->session_id,
        "/screenshot"
    );

    my $ua = $self->app->ua->get(
        $screenshot_url => {
            Connection => "TE, close",
            Accept => "application/json",
            TE  => "deflate,gzip;q=0.3",
        }, 
        json => {} 
    );

    warn "TOOK SCREENSHOT: ";
    warn $ua->res->body;
    my $image = decode_base64 $ua->res->json->{value};
    warn "STORE THE IMAGE SOMEWHERE...";
}

sub validate {
    my $self = shift;
    if ( ($self->req->url."") =~ m#/wd/hub/session/(?<session_id>[^/]+)/(url)#g ) {
        $self->session_id( $+{ session_id } );
        return 1;
    }
    return 0;
}

1;
