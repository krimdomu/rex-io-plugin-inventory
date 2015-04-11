#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::IO::Server::Inventory::Controller::Main;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON;
use Data::Dumper;
use DateTime;

sub register_plugin {
  my $self          = shift;
  my $rex_io_server = $self->config->{rex_io}->{server};
  my $my_domain     = $self->config->{rex_io}->{self};
  my $ua            = $self->ua;

  my $register_conf = {
    name    => "inventory",
    methods => [
      {
        url      => "/inventory",
        meth     => "POST",
        auth     => Mojo::JSON->false,
        location => "$my_domain/inventory",
      },
      {
        url      => "/inventory",
        meth     => "GET",
        auth     => Mojo::JSON->false,
        location => "$my_domain/inventory",
      },
      {
        url      => "/inventory/:hw_id",
        meth     => "GET",
        auth     => Mojo::JSON->false,
        location => "$my_domain/inventory/:hw_id",
      },
    ],
  };

  my $tx =
    $ua->post( "$rex_io_server/1.0/plugin/plugin", json => $register_conf );

  $self->render( json => $tx->res->json );
}

sub create {
  my $self = shift;
  $self->app->log->debug("Got Data to create inventory:");

  my $ref = $self->req->json->{data};
  $self->app->log->debug( Dumper( $ref ) );

  if ( exists $ref->{name} && exists $ref->{type} ) {
    $self->app->log->debug("Creating new inventory entry.");
    $ref->{c_date} = DateTime->now;
    $ref->{m_date} = DateTime->now;

    eval {
      $self->db->resultset("Hardware")->create($ref);
      1;
    } or do {
      $self->app->log->error("Creating new inventory entry: $@");
      return $self->render( json => { ok => Mojo::JSON->false, error => $@ } );
    };
    return $self->render( json => { ok => Mojo::JSON->true } );
  }

  $self->render( json => { ok => Mojo::JSON->false }, status => 500 );
}

sub read {
  my $self = shift;

  my $hw_id = $self->param("hw_id");
  $self->app->log->debug("Want to read hw item: $hw_id");

  my $hw = $self->db->resultset("Hardware")->find($hw_id);

  if ( !$hw ) {
    return $self->render(
      json   => { ok => Mojo::JSON->true, message => "Hardware not found." },
      status => 404
    );
  }

  $self->render(
    json => { ok => Mojo::JSON->true, data => [ $hw->all_data ] } );
}

sub read_all {
  my $self = shift;

  my $rs = $self->db->resultset("Hardware")->search(
    undef,
    {
      page => ( $self->param("page") || 1 ),
      rows => ( $self->param("rows") || 15 ),
    }
  );

  my @ret;
  while ( my $hw = $rs->next ) {
    push @ret, $hw->all_data;
  }

  $self->render( json => { ok => Mojo::JSON->true, data => \@ret } );
}

1;
