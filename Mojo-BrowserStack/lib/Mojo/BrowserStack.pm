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
    $self->init_browser_ip_map;
    $self->init_plugins;
    $self->init_routes_rest;

    $self->init_routes_selenium; #must be defined last
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

sub init_routes_selenium {
    my $self = shift;
    my $r = $self->routes;
#   $r->namespaces([qw|Mojo::BrowserStack::Controller|]);    
    $r->route('/wd/*')
        ->to( controller => 'SeleniumProxy' , action => 'forward' );
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

sub init_browser_ip_map {
    my $self = shift;
#   VBoxManage controlvm "IE10 - Win7" screenshotpng file.png
    my $browsers = {
        chrome => {
            1 => {
                ip   => '192.168.56.103',
                port => 4444,
                name => 'IE10 - Win7',
            },
            2 => {
                ip   => '192.168.56.103',
                port => 4444,
                name => 'IE8 - Win7',
            },
        },
        firefox => {
            1 => {
                ip   => '192.168.56.103',
                port => 4444,
                name => 'IE10 - Win7',
            },
            2 => {
                ip   => '192.168.56.103',
                port => 4444,
                name => 'IE8 - Win7',
            },
        }
    };
    $self->helper( browser => sub { $browsers } );
}

sub init_plugins {
    my $self = shift;

    require Mojo::BrowserStack::SeleniumServerInitializer;
    require Mojo::BrowserStack::SeleniumSessionInitializer;
    require Mojo::BrowserStack::SeleniumServerIpPortPatcher;
    require Mojo::BrowserStack::Screenshot;
    require Mojo::BrowserStack::Logger;
    my $plugin = {
        selenium_server_initializer => 
            Mojo::BrowserStack::SeleniumServerInitializer->new( app => $self ),
        selenium_session_initializer => 
            Mojo::BrowserStack::SeleniumSessionInitializer->new( app => $self ),
        selenium_server_ip_port_patcher =>
            Mojo::BrowserStack::SeleniumServerIpPortPatcher->new( app => $self ),
        screenshot =>
            Mojo::BrowserStack::Screenshot->new( app => $self ),
        logger =>
            Mojo::BrowserStack::Logger->new( app => $self ),
    };
    my $selenium_plugin = {
        before_selenium_request => [
            $plugin->{ selenium_server_initializer },
            $plugin->{ selenium_server_ip_port_patcher },
        ],
        after_selenium_request => [
            $plugin->{ selenium_session_initializer },
#           $plugin->{ screenshot },
#           $plugin->{ logger },
        ],
    };
    $self->helper( selenium_plugin => sub {
        $selenium_plugin
    } );
}

1;
