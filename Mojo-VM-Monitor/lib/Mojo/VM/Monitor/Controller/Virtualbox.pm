package Mojo::VM::Monitor::Controller::Virtualbox;
use base 'Mojolicious::Controller';
use Mojo::Asset::File;
use Digest::SHA1 qw|sha1_hex|;
use MIME::Base64;

sub screenshot {
    my $self = shift;
    my $machine_name = $self->param('machine_name');
    my $tempfile     = '/tmp/' . sha1_hex($machine_name);
    my $cmd          = "VBoxManage controlvm '$machine_name' screenshotpng $tempfile";
    `$cmd`;
    if ( -e $tempfile ) {
        my $file = Mojo::Asset::File->new( path => $tempfile );
        $self->render( data => $file->slurp, format => 'png' );
        unlink $tempfile;
    } else {
        my $IMG_NOT_FOUND = <<IMG;
R0lGODlhLAEGAaIAAN7e3vz8/Pn5+e3t7ePj4/Pz893d3f///yH/C1hNUCBEYXRhWE1QPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS4wLWMwNjEgNjQuMTQwOTQ5LCAyMDEwLzEyLzA3LTEwOjU3OjAxICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ1M1LjEgTWFjaW50b3NoIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOkM1RDlGODkxRDBDODExRTA4OTlGRUI2Njg5RjYwMjg1IiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOkM1RDlGODkyRDBDODExRTA4OTlGRUI2Njg5RjYwMjg1Ij4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6QzVEOUY4OEZEMEM4MTFFMDg5OUZFQjY2ODlGNjAyODUiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6QzVEOUY4OTBEMEM4MTFFMDg5OUZFQjY2ODlGNjAyODUiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz4B//79/Pv6+fj39vX08/Lx8O/u7ezr6uno5+bl5OPi4eDf3t3c29rZ2NfW1dTT0tHQz87NzMvKycjHxsXEw8LBwL++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
IMG
        $self->render( data => decode_base64($IMG_NOT_FOUND), format => 'gif' );
    }
}

#   sub take_screenshot {
#       my $self         = shift;
#       my $machine_name = shift;
#       my $tempfile     = '/tmp/' . ( sha1_hex rand );
#       my $cmd = "VBoxManage controlvm '$machine_name' screenshotpng $tempfile";
#       `$cmd`;
#       $self->upload_screenshot( $machine_name, $tempfile ) if -e $tempfile;
#       unlink $tempfile;
#   }

#   sub upload_screenshot {
#       my $self         = shift;
#       my $machine_name = shift;
#       my $filename     = shift;

#       #   my $file = io( shift )->slurp;
#       $self->ua->post(
#           $self->url_upload => form => {
#               server_host  => '192.168.111.xxx',
#               machine_name => $machine_name,
#               image        => {
#                   file => $filename
#               }
#           }
#       );
#   }

#   sub list_all_vm {
#       my $self = shift;
#       my $cmd  = 'VBoxManage list runningvms';
#       open( my $fh, "-|", $cmd );

#       #use IPC::Run "run"; run [ "VBoxManage", "vms", "list" ], ">", \my $stdout;
#       #print <$fh>
#       my @vms = ();
#       while (<$fh>) {
#           my ( $vm_name, $vm_id ) = $_ =~ m#^"(.+)" \{([^\}]+)\}$#g;
#           push @vms, $vm_name;
#       }
#       \@vms;
#   }

1;
