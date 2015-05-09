package Mojo::BrowserStack;
use Mojo::Base 'Mojolicious';
use Mojo::BrowserStack::DB;

our $VERSION = 0.01;

sub startup {
    my $self = shift;
#   $self->plugin('BasicAuth');

    my $db = Mojo::BrowserStack::DB->new(
        dsn                 => $ENV{BROWSERSTACK_DSN},
        filepath_migrations => $ENV{BROWSERSTACK_MIGRATIONS},
    );
    $self->helper( db => sub { $db } );

    my $r = $self->routes;
    $r->namespaces([qw|Mojo::BrowserStack::Controller|]);
    $r->route('/')
        ->to( controller => 'Home' , action => 'index' );

    $self->init_routes_admin;
    $self->init_routes_auth;
    $self->init_selenium_session_map;
    $self->init_routes_rest;

}

sub init_routes_rest {
    my $self = shift;
    my $r = $self->routes;
    $r->route( '/v1/user/sessions' )
        ->name('user_sessions')
        ->to( controller => 'RestUser', action => 'sessions' );
    $r->route( '/v1/test/:test_id' )
        ->name('test_detail')
        ->to( controller => 'RestUser', action => 'test_detail' );
    $r->route( '/v1/user/profile' )
        ->name('user_profile')
        ->to( controller => 'RestUser', action => 'user_profile' );
#   $r->route( '/v1/vm/screenshot/:session_id' )
#       ->name('vm_screenshot')
#       ->to( controller => 'RestUser', action => 'vm_screenshot' );
}

sub init_routes_auth {
    my $self = shift;
    my $r = $self->routes;
#   $r->namespaces([qw|Mojo::BrowserStack::Controller|]);    
    $r->route("/login")
        ->name('login')
        ->to( controller => 'Auth', action => 'login' );
    $r->route("/logout")
        ->name('logout')
        ->to( controller => 'Auth', action => 'logout' );
    $r->route("/signup")
        ->name('signup')
        ->to( controller => 'Auth', action => 'signup' );
}

sub init_routes_admin {
    my $self = shift;
    my $r = $self->routes;
#   $r->namespaces([qw|Mojo::BrowserStack::Controller|]);    
    $r->route("/admin")
        ->name('admin_home')
        ->to( controller => 'Admin', action => 'index' );
#   $r->route( '/v1/screenshot/' )
#       ->name('upload_vm_screenshot')
#       ->to( controller => 'VM', action => 'screenshot_upload' );

}

sub init_selenium_session_map {
    my $self = shift;
    my $selenium_session = {};
    $self->helper( selenium_session => sub { $selenium_session } );
}

1;
