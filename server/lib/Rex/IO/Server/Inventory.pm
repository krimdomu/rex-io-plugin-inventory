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

sub update_inventory_for_server {
  my ($self) = @_;
  my $ip = ip_to_int( $self->tx->remote_address );

  $self->app->log->debug("Searching host with ip $ip");
  my $json = $self->req->json;

  $self->app->log->debug( Dumper($json) );

  $self->_normalize_fi($json);

  my $hostname = $self->_get_hostname($json);
  my $host     = $self->_get_hw($json);

  if ( !$host ) {

    # hardware does not exists, yet
    try {
      my $new_hw = $self->db->resultset("Hardware")->create(
        {
          name     => $hostname,
          uuid     => $json->{info}->{CONTENT}->{HARDWARE}->{UUID} || '',
          state_id => (
            exists $json->{info}->{inventory}
              && $json->{info}->{inventory}->{state} eq "inventory"
            ? 5
            : 4
          ),
          os_template_id =>
            ( $self->config->{defaults}->{new_system}->{os_template} || 1 ),
        }
      );

      $self->inventor( $new_hw, $json->{info} );
      $self->render( json => { ok => Mojo::JSON->true } );
      1;
    }
    catch {
      $self->app->log->error(
        "Error saving new systen in database.\n\nERROR: $_\n\n");
      $self->render( json => { ok => Mojo::JSON->false }, status => 500 );
    };

  }
  else {
    try {
      $self->app->log->debug("Hardware already registered. Updating.");
      $self->inventor( $host, $json->{info} );

      $host->update(
        {
          state_id => (
            exists $json->{info}->{inventory}
              && $json->{info}->{inventory}->{state} eq "inventory" ? 5 : 4
          ),
          name => $hostname,
        }
      );

      $self->render( json => { ok => Mojo::JSON->true } );
      1;
    }
    catch {
      $self->app->log->error(
        "Error saving new systen in database.\n\nERROR: $_\n\n");
      $self->render( json => { ok => Mojo::JSON->false }, status => 500 );
    };
  }
}

sub _normalize_fi {
  my ( $self, $json ) = @_;

  # normalizing fusioninventory array
  # convert to array if not array
  if ( ref( $json->{info}->{CONTENT}->{STORAGES} ) ne "ARRAY" ) {
    $json->{info}->{CONTENT}->{STORAGES} =
      [ $json->{info}->{CONTENT}->{STORAGES} ];
  }
  if ( ref( $json->{info}->{CONTENT}->{NETWORKS} ) ne "ARRAY" ) {
    $json->{info}->{CONTENT}->{NETWORKS} =
      [ $json->{info}->{CONTENT}->{NETWORKS} ];
  }
  if ( ref( $json->{info}->{CONTENT}->{MEMORIES} ) ne "ARRAY" ) {
    $json->{info}->{CONTENT}->{MEMORIES} =
      [ $json->{info}->{CONTENT}->{MEMORIES} ];
  }
  if ( ref( $json->{info}->{CONTENT}->{CPUS} ) ne "ARRAY" ) {
    $json->{info}->{CONTENT}->{CPUS} =
      [ $json->{info}->{CONTENT}->{CPUS} ];
  }

  if ( ref $json->{info}->{CONTENT}->{HARDWARE}->{UUID} ) {

    # no mainboard uuid
    my ($uuid_r) = grep { $_->{MACADDR} !~ m/^00:00:00/ }
      @{ $json->{info}->{CONTENT}->{NETWORKS} };
    $json->{info}->{CONTENT}->{HARDWARE}->{UUID} = $uuid_r->{MACADDR};
  }

  if ( !exists $json->{info}->{CONTENT}->{HARDWARE}->{UUID}
    || !$json->{info}->{CONTENT}->{HARDWARE}->{UUID} )
  {
    # no mainboard uuid
    my ($uuid_r) = grep { $_->{MACADDR} !~ m/^00:00:00/ }
      @{ $json->{info}->{CONTENT}->{NETWORKS} };
    $json->{info}->{CONTENT}->{HARDWARE}->{UUID} = $uuid_r->{MACADDR};
  }

}

sub _get_hostname {
  my ( $self, $json ) = @_;

  my @mac_addresses = $self->_get_mac_addresses($json);

  # getting hostname and looking for system uuid.
  # if no uuid we're using mac addr for system idenification
  my $hostname = $json->{info}->{CONTENT}->{HARDWARE}->{NAME};

  if ( exists $json->{info}->{use_mac} && $json->{info}->{use_mac} ) {
    ($hostname) = grep { !m/^00:00:00/ } @mac_addresses;
    $hostname =~ s/:/-/g;
  }

  if ( exists $json->{info}->{sysinfo}
    && exists $json->{info}->{sysinfo}->{hostname} )
  {
    $hostname = $json->{info}->{sysinfo}->{hostname};
  }

  return $hostname;
}

sub _get_mac_addresses {
  my ( $self, $json ) = @_;

  my @mac_addresses = ();
  for my $eth ( @{ $json->{info}->{CONTENT}->{NETWORKS} } ) {
    next if ( ! exists $eth->{MACADDR} );
    next if ( $eth->{MACADDR} =~ m/^00:00:00/ );
    next
      if ( $eth->{MACADDR} eq "fe:ff:ff:ff:ff:ff" );    # skip xen things...

    push @mac_addresses, $eth->{MACADDR};
  }

  return @mac_addresses;
}

sub _get_hw {
  my ( $self, $json ) = @_;

  my @mac_addresses = $self->_get_mac_addresses($json);

  my $hw = $self->db->resultset("Hardware")->search(
    {
      "network_adapters.mac" => { "-in" => \@mac_addresses }
    },
    {
      join => "network_adapters",
    }
  );

  return $hw->first;
}

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

  # update / add inventory
  $r->post("/1.0/inventory/server")
    ->to("inventory#update_inventory_for_server");

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
