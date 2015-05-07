package Mojo::BrowserStack::Controller::RestUser;
use base 'Mojolicious::Controller';
use IO::All;
use MIME::Base64;

=head3 sessions 

List user sessions

=cut

sub sessions {
    my $self = shift;
    $self->respond_to( json => sub {
        my $self = shift;
        my $sessions = $self->db->user_sessions( $self->session( 'user_id' ) );
        $self->render( json => { sessions => $sessions } );
    } );
}

sub test_detail {
    my $self = shift;
    $self->respond_to( json => sub {
        my $self = shift;
        my $session = $self->db->session_detail( $self->param('test_id') );
        my $test = $self->db->test_detail( $self->param('test_id') );
        $self->render( json => { result => $test , session => $session->[0] } );
    } );
}

sub user_profile {
    my $self = shift;
    $self->respond_to( json => sub {
        my $self = shift;
        my $profile = $self->db->user_profile( $self->session( 'username' ) );
        $self->render( json => { result => $profile } );
    } );
}

#   sub vm_screenshot {
#       my $self = shift;
#   #   warn "Bater no servidor de screenshots e pegar as informações da vm";
#   #   warn "Buscar o nome da VM a partir do selenium session id. tem que salvar essa info no banco..";
#       my $session = $self->db->find_session( $self->param('session_id') );
#       my $vmname = $session->{vm_name};
#       #TODO: botar o ip da maquina certo.. agora ta localhost mas no futuro não

#       my $vm_server_url = 'http://localhost:8002/screenshot/vbox/'.$vmname;
#       $self->ua->get( $vm_server_url => {} => json => {} => sub {
#           my $ua = shift;
#           my $tx = shift;
#           $self->render( data => $tx->res->body, format => 'png' );
#       } );
#   }

1;
