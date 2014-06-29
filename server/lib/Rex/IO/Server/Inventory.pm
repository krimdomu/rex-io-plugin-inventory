#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::IO::Server::Inventory;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use Carp;
use Try::Tiny;
use Rex::IO::Server::Helper::IP;
use Rex::IO::Server::Helper::Inventory;



################################################################################
# manage network adapters
################################################################################
sub list_network_adapter {
  my ($self) = @_;
  my $hardware_id = $self->param("hardware_id");

  my $hw = $self->db->resultset("Hardware")->find($hardware_id);
  if ( !$hw ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Hardware not found." },
      status => 404
    );
  }

  if ( !$hw->has_perm( 'READ', $self->current_user ) ) {
    return $self->render(
      json => {
        ok    => Mojo::JSON->false,
        error => 'No permission to read hardware.'
      },
      status => 403
    );
  }

  my $ret = $hw->to_hashRef()->{network_adapters};

  $self->render( json => { ok => Mojo::JSON->true, data => $ret } );
}

sub add_network_adapter {
  my ($self) = @_;

  my $ref         = $self->req->json;
  my $hardware_id = $self->param("hardware_id");

  $ref->{hardware_id} = $hardware_id;

  $self->app->log->debug("Adding new network adapter for $hardware_id.");
  $self->app->log->debug( Dumper($ref) );

  my $hw = $self->db->resultset("Hardware")->find($hardware_id);
  if ( !$hw ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Hardware not found." },
      status => 404
    );
  }

  if ( !$hw->has_perm( 'MODIFY', $self->current_user ) ) {
    return $self->render(
      json => {
        ok    => Mojo::JSON->false,
        error => 'No permission to modify hardware.'
      },
      status => 403
    );
  }

  try {
    for my $k (qw/ip netmask network gateway broadcast/) {
      $ref->{$k} = ip_to_int $ref->{$k} if ( exists $ref->{$k} && $ref->{$k} );
      $ref->{"wanted_$k"} = ip_to_int $ref->{$k}
        if ( exists $ref->{$k} && $ref->{$k} );
    }

    my $nwa = $self->db->resultset("NetworkAdapter")->create($ref);

    $self->render(
      json => { ok => Mojo::JSON->true, data => $nwa->to_hashRef() } );
  }
  catch {
    $self->app->log->error(
      "Error adding new network adapter:\n\nERROR: $_\n\n");
    $self->render(
      json   => { ok => Mojo::JSON->false, error => $_ },
      status => 500
    );
  };
}

sub del_network_adapter {
  my ($self) = @_;

  my $hardware_id        = $self->param("hardware_id");
  my $network_adapter_id = $self->param("network_adapter_id");

  my $hw = $self->db->resultset("Hardware")->find($hardware_id);
  if ( !$hw ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Hardware not found." },
      status => 404
    );
  }

  if ( !$hw->has_perm( 'MODIFY', $self->current_user ) ) {
    return $self->render(
      json => {
        ok    => Mojo::JSON->false,
        error => 'No permission to modify hardware.'
      },
      status => 403
    );
  }

  my $nwa = $self->db->resultset("NetworkAdapter")->find($network_adapter_id);
  if ( !$nwa ) {
    return $self->render(
      json =>
        { ok => Mojo::JSON->false, error => "Network Adapter not found." },
      status => 404
    );
  }

  $nwa->delete;

  $self->render( json => { ok => Mojo::JSON->true } );
}

sub get_network_adapter {
  my ($self) = @_;

  my $hardware_id        = $self->param("hardware_id");
  my $network_adapter_id = $self->param("network_adapter_id");

  my $hw = $self->db->resultset("Hardware")->find($hardware_id);
  if ( !$hw ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Hardware not found." },
      status => 404
    );
  }

  if ( !$hw->has_perm( 'READ', $self->current_user ) ) {
    return $self->render(
      json => {
        ok    => Mojo::JSON->false,
        error => 'No permission to read hardware.'
      },
      status => 403
    );
  }

  my $nwa = $self->db->resultset("NetworkAdapter")->find($network_adapter_id);
  if ( !$nwa ) {
    return $self->render(
      json =>
        { ok => Mojo::JSON->false, error => "Network Adapter not found." },
      status => 404
    );
  }

  $self->render(
    json => { ok => Mojo::JSON->true, data => $nwa->to_hashRef() } );
}

sub update_network_adapter {
  my ($self) = @_;

  my $hardware_id        = $self->param("hardware_id");
  my $network_adapter_id = $self->param("network_adapter_id");

  my $hw = $self->db->resultset("Hardware")->find($hardware_id);
  if ( !$hw ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Hardware not found." },
      status => 404
    );
  }

  if ( !$hw->has_perm( 'MODIFY', $self->current_user ) ) {
    return $self->render(
      json => {
        ok    => Mojo::JSON->false,
        error => 'No permission to modify hardware.'
      },
      status => 403
    );
  }

  my $nwa = $self->db->resultset("NetworkAdapter")->find($network_adapter_id);
  if ( !$nwa ) {
    return $self->render(
      json =>
        { ok => Mojo::JSON->false, error => "Network Adapter not found." },
      status => 404
    );
  }

  eval {
    $self->app->log->debug( "Updating network adapter: " . $nwa->id );
    $self->app->log->debug( Dumper( $self->req->json ) );

    my $ref = $self->req->json;

    for my $k (qw/ip netmask network gateway broadcast/) {
      $ref->{$k} = ip_to_int $ref->{$k}
        if ( exists $ref->{$k} && $ref->{$k} )
        ;    # beachten: nicht im inventory state
      $ref->{"wanted_$k"} = ip_to_int $ref->{$k}
        if ( exists $ref->{$k} && $ref->{$k} );
    }

    $nwa->update($ref);
    1;
  } or do {
    $self->app->log->error("Error updating network adapter: $@");
    return $self->render(
      json  => { ok => Mojo::JSON->false, error => "Error: $@" },
      error => 500
    );
  };

  $self->render(
    json => { ok => Mojo::JSON->true, data => $nwa->to_hashRef() } );
}

################################################################################
# manage bridges
################################################################################
# create a new bridge
sub add_bridge {
  my ($self) = @_;

  my $ref         = $self->req->json;
  my $hardware_id = $self->param("hardware_id");

  $ref->{hardware_id} = $hardware_id;

  my $hw = $self->db->resultset("Hardware")->find($hardware_id);
  if ( !$hw ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Hardware not found." },
      status => 404
    );
  }

  if ( !$hw->has_perm( 'MODIFY', $self->current_user ) ) {
    return $self->render(
      json => {
        ok    => Mojo::JSON->false,
        error => 'No permission to modify hardware.'
      },
      status => 403
    );
  }

  for my $k (qw/ip netmask network gateway broadcast/) {
    $ref->{$k} = ip_to_int $ref->{$k}
      if ( exists $ref->{$k} && $ref->{$k} )
      ;    # beachten: nicht im inventory state
  }

  my $bridge = $self->db->resultset("NetworkBridge")->create($ref);

  $self->render(
    json => { ok => Mojo::JSON->true, data => $bridge->to_hashRef() } );
}

# list bridges
sub list_bridges {
  my ($self) = @_;

  my $hardware_id = $self->param("hardware_id");

  my $hw = $self->db->resultset("Hardware")->find($hardware_id);
  if ( !$hw ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Hardware not found." },
      status => 404
    );
  }

  if ( !$hw->has_perm( 'READ', $self->current_user ) ) {
    return $self->render(
      json => {
        ok    => Mojo::JSON->false,
        error => 'No permission to read hardware.'
      },
      status => 403
    );
  }

  my @all_bridges = $self->db->resultset("NetworkBridge")
    ->search( { hardware_id => $self->param("hardware_id") } );

  my $ret = [];
  for my $br (@all_bridges) {
    push @{$ret}, $br->to_hashRef;
  }

  $self->render( json => { ok => Mojo::JSON->true, data => $ret } );
}

# delete bridge
sub del_bridge {
  my ($self) = @_;

  my $hardware_id = $self->param("hardware_id");
  my $bridge_id   = $self->param("bridge_id");

  my $hw = $self->db->resultset("Hardware")->find($hardware_id);
  if ( !$hw ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Hardware not found." },
      status => 404
    );
  }

  if ( !$hw->has_perm( 'MODIFY', $self->current_user ) ) {
    return $self->render(
      json => {
        ok    => Mojo::JSON->false,
        error => 'No permission to modify hardware.'
      },
      status => 403
    );
  }

  my $br = $self->db->resultset("NetworkBridge")->find($bridge_id);
  if ( !$br ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Bridge not found." },
      status => 404
    );
  }

  $br->delete;

  $self->render( json => { ok => Mojo::JSON->true } );
}

sub get_bridge {
  my ($self) = @_;

  my $hardware_id = $self->param("hardware_id");
  my $bridge_id   = $self->param("bridge_id");

  my $hw = $self->db->resultset("Hardware")->find($hardware_id);
  if ( !$hw ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Hardware not found." },
      status => 404
    );
  }

  if ( !$hw->has_perm( 'READ', $self->current_user ) ) {
    return $self->render(
      json => {
        ok    => Mojo::JSON->false,
        error => 'No permission to read hardware.'
      },
      status => 403
    );
  }

  my $br = $self->db->resultset("NetworkBridge")->find($bridge_id);
  if ( !$br ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Bridge not found." },
      status => 404
    );
  }

  $self->render(
    json => { ok => Mojo::JSON->true, data => $br->to_hashRef() } );
}

sub update_bridge {
  my ($self) = @_;

  my $hardware_id = $self->param("hardware_id");
  my $bridge_id   = $self->param("bridge_id");

  my $hw = $self->db->resultset("Hardware")->find($hardware_id);
  if ( !$hw ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Hardware not found." },
      status => 404
    );
  }

  if ( !$hw->has_perm( 'MODIFY', $self->current_user ) ) {
    return $self->render(
      json => {
        ok    => Mojo::JSON->false,
        error => 'No permission to modify hardware.'
      },
      status => 403
    );
  }

  my $br = $self->db->resultset("NetworkBridge")->find($bridge_id);
  if ( !$br ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Bridge not found." },
      status => 404
    );
  }

  eval {
    $self->app->log->debug( "Updating bridge: " . $br->id );
    $self->app->log->debug( Dumper( $self->req->json ) );

    my $ref = $self->req->json;

    for my $k (qw/ip netmask network gateway broadcast/) {
      $ref->{$k} = ip_to_int $ref->{$k} if ( exists $ref->{$k} && $ref->{$k} );
    }

    $br->update($ref);
    1;
  } or do {
    $self->app->log->error("Error updating bridge: $@");
    return $self->render(
      json  => { ok => Mojo::JSON->false, error => "Error: $@" },
      error => 500
    );
  };

  $self->render(
    json => { ok => Mojo::JSON->true, data => $br->to_hashRef() } );
}

sub __register__ {
  my ( $self, $app ) = @_;
  my $r = $app->routes;

  # bridge adapter operations
  $r->get("/1.0/inventory/host/:hardware_id/bridge/:bridge_id")
    ->over( authenticated => 1 )->to("inventory#get_bridge");

  $r->post("/1.0/inventory/host/:hardware_id/bridge")
    ->over( authenticated => 1 )->to("inventory#add_bridge");

  $r->post("/1.0/inventory/host/:hardware_id/bridge/:bridge_id")
    ->over( authenticated => 1 )->to("inventory#update_bridge");

  $r->get("/1.0/inventory/host/:hardware_id/bridge")
    ->over( authenticated => 1 )->to("inventory#list_bridges");

  $r->delete("/1.0/inventory/host/:hardware_id/bridge/:bridge_id")
    ->over( authenticated => 1 )->to("inventory#del_bridge");

  # network adapter operation
  $r->get(
    "/1.0/inventory/host/:hardware_id/network_adapter/:network_adapter_id")
    ->over( authenticated => 1 )->to("inventory#get_network_adapter");

  $r->post("/1.0/inventory/host/:hardware_id/network_adapter")
    ->over( authenticated => 1 )->to("inventory#add_network_adapter");

  $r->post(
    "/1.0/inventory/host/:hardware_id/network_adapter/:network_adapter_id")
    ->over( authenticated => 1 )->to("inventory#update_network_adapter");

  $r->get("/1.0/inventory/host/:hardware_id/network_adapter")
    ->over( authenticated => 1 )->to("inventory#list_network_adapter");

  $r->delete(
    "/1.0/inventory/host/:hardware_id/network_adapter/:network_adapter_id")
    ->over( authenticated => 1 )->to("inventory#del_network_adapter");

}

1;
