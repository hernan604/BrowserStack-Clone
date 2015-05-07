package Mojo::BrowserStack::Controller::Auth;
use base 'Mojolicious::Controller';

sub login {
    my $self = shift;
    $self->respond_to( json => sub {
        my $self = shift;
        ( $self->req->method eq 'PUT' )
            ? $self->do_login
            : $self->render( json => { status => 'ERROR' } )
            ;
    }, html => sub {
        my $self = shift;
        $self->render( '/v1/admin/login' );
    } );
}

sub render_errors {
    my $self = shift;
    my $errors = shift;
    $self->render( json => { status => 'ERROR', errors => $errors } ); 
}

sub logout {
    my $self = shift;
    $self->session( username => undef );
    $self->session( user_id => undef );
    $self->redirect_to( '/' );
}

sub do_login {
    my $self = shift;
    $self->render_errors( [ 'Please fill in username and password' ] )
        and return
        if ! $self->validate;
    my $user = $self->db->user_find( 
        $self->req->json->{ username } , 
        $self->req->json->{ password } );

    $self->render_errors( [ 'Wrong username or password' ] )
        and return 
        if ! $user || ! $user->{ id };

    $self->session( user_id => $user->{ id } );
    $self->session( username => $user->{ username } );

    $self->render( json => {
        status => 'OK',
        redirect => $self->url_for('admin_home')
    } );
}

sub validate {
    my $self = shift;
    my $errors = [];
    if ( ! $self->req->json->{ username } || ! $self->req->json->{ password } ) {
        $self->render( json => {
            status => 'ERROR',
            errors => $errors
        } );
        return 0;
    }
    return 1;
}

sub validate_signup {
    my $self = shift;
    return 
        defined $self->req->json
        and exists $self->req->json->{ email }
        and exists $self->req->json->{ password }
        and exists $self->req->json->{ username }
        ;
}

sub signup {
    my $self = shift;
    $self->respond_to( html => sub {
        my $self = shift;
        $self->render( 'v1/signup' );
    }, json => sub {
        my $self = shift;
        my $errors = [];
        if ( $self->req->method eq 'PUT' ) {
            push @{ $errors }, 'Please fill complete information before submission'
                if !$self->validate_signup;
            my $new_user = $self->req->json;
            my $success = 0;

            my $is_avail = $self->db->user_is_avaliable(
                    $self->req->json->{username}, 
                    $self->req->json->{email} );
            if ( !@{$errors} and $is_avail ) {
                my $user = $self->db->user_register( $self->req->json );
                $self->session( user_id => $user->{ id } );
                $self->session( username => $self->req->json->{ username } );
            } else {
                push @{$errors}, "Username or email is already in use. Please chose another." if ! $is_avail;
            }
            $self->render( json =>
                ( scalar @{ $errors } )
                    ? { status => 'ERROR', errors => $errors }
                    : { status => 'OK', redirect => $self->url_for( 'admin_home' ) }
            );
        }
    } );
}

1;
