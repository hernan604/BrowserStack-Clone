package Mojo::BrowserStack::DB;
use Moo;
use Mojo::Pg;

has [
    qw|
      dsn
      filepath_migrations
      |
] => ( is => 'rw' );

has pg => (
    is      => 'rw',
    default => sub {
        my $self = shift;
        my $pg   = Mojo::Pg->new( $self->dsn );
        $pg->max_connections(5);
        $pg;
    }
);

sub migrate {
    my $self = shift;
    if ( $self->filepath_migrations ) {
        $self->pg->migrations->from_file( $self->filepath_migrations )->migrate;
    }
}

sub BUILD {
    my $self = shift;
    $self->migrate;
}

sub user_sessions {
    my $self = shift;
    $self->pg->db
        ->query(<<QUERY, shift )->hashes->to_array;
    SELECT id, created, status, browser, version, platform, name, tags
    FROM "SeleniumSession" 
    WHERE user_id = ?
    ORDER BY created desc
QUERY
}

sub test_detail {
    my $self = shift;
    $self->pg->db
        ->query(<<QUERY, shift )->hashes->to_array;
    SELECT id, selenium_session_id as test_id, created, action, elapsed 
    FROM "SeleniumLog" WHERE selenium_session_id = ?
    ORDER BY created ASC;
QUERY
}

sub session_detail {
    my $self = shift;
    $self->pg->db
        ->query(<<QUERY, shift )->hashes->to_array;
    SELECT *
    FROM "SeleniumSession" WHERE id = ?
QUERY
}

sub user_profile {
    my $self = shift;
    $self->pg->db->query(<<Q, shift)->hashes->to_array->[0];
    SELECT * 
    FROM "User" where username = ?
Q
}

sub user_find {
    my $self = shift;
    $self->pg->db
        ->query('select id,username,email from "User" where username = ? and password = ?', shift, shift)
        ->hashes
        ->to_array->[0]
        ;
}

sub user_is_avaliable {
    my $self = shift;
    my $users = $self->pg->db
        ->query(<<QUERY, shift, shift );
    select id from "User" where username = ? or email = ?
QUERY
    return $users->rows > 0
        ? 0 #found user in db ? return 0
        : 1 #not found user in db? return 1
        ;
}

sub user_register {
    my $self = shift;
    my $new_user = shift;
    my $user = $self->pg->db
        ->query( <<QUERY, $new_user->{username}, $new_user->{password}, $new_user->{email} )->hashes->to_array->[0];
    INSERT INTO "User" 
        (username,password,email) 
    VALUES 
        (?,?,?)
    returning id
QUERY
    $user;
}

sub selenium_session_create {
    my $self = shift;
    #id,user_id,status,browser,version,platform,host,port
    $self->pg->db
        ->query( <<QUERY, shift, shift, shift, shift, shift, shift, shift, shift, shift, shift, shift, shift );
            insert into "SeleniumSession" 
                (id,user_id,status,browser,version,platform,host,port,name,tags,vm_name,vm_host_ip) 
                values 
                (?,?,?,?,?,?,?,?,?,?,?,?)
QUERY
}

sub selenium_session_finalize {
    my $self = shift;
    $self->pg->db->query(<<Q, shift );
    UPDATE "SeleniumSession" set status = 'done' where id = ?
Q
}

sub selenium_log_create {
    my $self = shift;
    $self->pg->db
        ->query(<<QUERY, shift, shift, shift );
            INSERT INTO "SeleniumLog"
            (selenium_session_id, action, elapsed)
            VALUES
            (?,?,?)
QUERY
}

sub find_session {
    my $self = shift;
    $self->pg->db->query(<<Q, shift )->hashes->to_array->[0];
    select * from "SeleniumSession" where id = ?
Q
}

1;
