package Rex::IO::WebUI::Inventory;

use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;
use File::Basename;

################################################################################
# Network Adapter functions
################################################################################
sub get_network_adapter {
  my ($self) = @_;

  my $ref = $self->rexio->call(
    GET => "1.0",
    "inventory",
    host            => $self->param("server_id"),
    network_adapter => $self->param("network_adapter_id")
  );

  if ( exists $ref->{data} ) {
    return $self->render( json => $ref->{data} );
  }

  $self->render( json => $ref );
}

sub update_network_adapter {
  my ($self) = @_;

  $self->app->log->debug(
    "Updating network adapter: " . $self->param("network_adapter_id") );
  $self->app->log->debug( Dumper( $self->req->json ) );

  my $ref = $self->rexio->call(
    POST => "1.0",
    "inventory",
    host            => $self->param("server_id"),
    network_adapter => $self->param("network_adapter_id"),
    ref             => $self->req->json->{data}
  );

  $self->render( json => $ref );
}

sub add_network_adapter {
  my ($self) = @_;

  $self->app->log->debug("Adding new network adapter");
  $self->app->log->debug( Dumper( $self->req->json ) );

  my $ref = $self->rexio->call(
    POST => "1.0",
    "inventory",
    host            => $self->param("server_id"),
    network_adapter => undef,
    ref             => $self->req->json->{data}
  );

  $self->render( json => $ref );
}

sub delete_network_adapter {
  my ($self) = @_;

  my $ref = $self->rexio->call(
    DELETE => "1.0",
    "inventory",
    host            => $self->param("server_id"),
    network_adapter => $self->param("network_adapter_id")
  );

  $self->render( json => $ref );
}

################################################################################
# Bridge functions
################################################################################
sub update_bridge {

  my ($self) = @_;

  $self->app->log->debug( "Updating bridge: " . $self->param("bridge_id") );
  $self->app->log->debug( Dumper( $self->req->json ) );

  my $ref = $self->rexio->call(
    POST => "1.0",
    "inventory",
    host   => $self->param("server_id"),
    bridge => $self->param("bridge_id"),
    ref    => $self->req->json->{data}
  );

  $self->render( json => $ref );
}

sub add_bridge {

  my ($self) = @_;

  $self->app->log->debug("Adding new bridge ");
  $self->app->log->debug( Dumper( $self->req->json ) );

  my $ref = $self->rexio->call(
    POST => "1.0",
    "inventory",
    host   => $self->param("server_id"),
    bridge => undef,
    ref    => $self->req->json->{data}
  );

  $self->render( json => $ref );
}

sub delete_bridge {
  my ($self) = @_;

  my $ref = $self->rexio->call(
    DELETE => "1.0",
    "inventory",
    host   => $self->param("server_id"),
    bridge => $self->param("bridge_id")
  );

  $self->render( json => $ref );
}

sub get_bridge {
  my ($self) = @_;

  my $ref = $self->rexio->call(
    GET => "1.0",
    "inventory",
    host   => $self->param("server_id"),
    bridge => $self->param("bridge_id")
  );

  if ( exists $ref->{data} ) {
    return $self->render( json => $ref->{data} );
  }

  $self->render( json => $ref );
}

##### Rex.IO WebUI Plugin specific methods
sub __register__ {
  my ( $self, $opt ) = @_;
  my $r      = $opt->{route};
  my $r_auth = $opt->{route_auth};
  my $app    = $opt->{app};

  $r_auth->get(
    "/1.0/inventory/host/:server_id/network_adapter/:network_adapter_id")
    ->to("inventory#get_network_adapter");

  $r_auth->post("/1.0/inventory/host/:server_id/network_adapter")
    ->to("inventory#add_network_adapter");

  $r_auth->post(
    "/1.0/inventory/host/:server_id/network_adapter/:network_adapter_id")
    ->to("inventory#update_network_adapter");

  $r_auth->delete(
    "/1.0/inventory/host/:server_id/network_adapter/:network_adapter_id")
    ->to("inventory#delete_network_adapter");

  $r_auth->get("/1.0/inventory/host/:server_id/bridge/:bridge_id")
    ->to("inventory#get_bridge");

  $r_auth->post("/1.0/inventory/host/:server_id/bridge")
    ->to("inventory#add_bridge");

  $r_auth->post("/1.0/inventory/host/:server_id/bridge/:bridge_id")
    ->to("inventory#update_bridge");

  $r_auth->delete("/1.0/inventory/host/:server_id/bridge/:bridge_id")
    ->to("inventory#delete_bridge");

  # add plugin template path
  push( @{ $app->renderer->paths }, dirname(__FILE__) . "/templates" );
  push( @{ $app->static->paths },   dirname(__FILE__) . "/public" );
}

1;
