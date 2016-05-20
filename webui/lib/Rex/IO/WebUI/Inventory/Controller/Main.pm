package Rex::IO::WebUI::Inventory::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub register_plugin {
  my $self         = shift;
  my $rex_io_webui = $self->config->{rex_io}->{webui};
  my $my_domain    = $self->config->{rex_io}->{self};
  my $ua           = $self->ua;

  my $register_conf = {
    name    => "inventory",
    methods => [
      # templates
      {
        url      => "/inventory/template",
        meth     => "GET",
        auth     => Mojo::JSON->true,
        location => "$my_domain/template",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/inventory/template/types",
        meth     => "GET",
        auth     => Mojo::JSON->true,
        location => "$my_domain/template/types",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/inventory/template/dt/columns",
        meth     => "GET",
        auth     => Mojo::JSON->true,
        location => "$my_domain/template/dt/columns",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/inventory/template/dt/rows",
        meth     => "GET",
        auth     => Mojo::JSON->true,
        location => "$my_domain/template/dt/rows",
        root     => Mojo::JSON->true,
      },

      # inventory
      {
        url      => "/inventory/:group_id",
        meth     => "GET",
        auth     => Mojo::JSON->true,
        location => "$my_domain/inventory/:group_id",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/inventory/asset/server/new",
        meth     => "GET",
        auth     => Mojo::JSON->true,
        location => "$my_domain/inventory/asset/server/new",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/inventory/asset/:asset_id",
        meth     => "GET",
        auth     => Mojo::JSON->true,
        location => "$my_domain/inventory/asset/:asset_id",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/inventory/asset/:asset_id/tabs",
        meth     => "GET",
        auth     => Mojo::JSON->true,
        location => "$my_domain/inventory/asset/:asset_id/tabs",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/inventory/dt/columns",
        meth     => "GET",
        auth     => Mojo::JSON->true,
        location => "$my_domain/inventory/dt/columns",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/inventory/dt/rows/:group_id",
        meth     => "GET",
        auth     => Mojo::JSON->true,
        location => "$my_domain/inventory/dt/rows/:group_id",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/js/inventory.js",
        meth     => "GET",
        auth     => Mojo::JSON->false,
        location => "$my_domain/js/inventory.js",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/js/inventory/templates.js",
        meth     => "GET",
        auth     => Mojo::JSON->false,
        location => "$my_domain/js/inventory/templates.js",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/js/inventory/asset.js",
        meth     => "GET",
        auth     => Mojo::JSON->false,
        location => "$my_domain/js/inventory/asset.js",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/js/inventory/group.js",
        meth     => "GET",
        auth     => Mojo::JSON->false,
        location => "$my_domain/js/inventory/group.js",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/js/inventory/asset/server.js",
        meth     => "GET",
        auth     => Mojo::JSON->false,
        location => "$my_domain/js/inventory/asset/server.js",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/inventory/types",
        meth     => "GET",
        auth     => Mojo::JSON->true,
        location => "$my_domain/inventory/types",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/inventory",
        meth     => "POST",
        auth     => Mojo::JSON->true,
        location => "$my_domain/inventory/asset",
        root     => Mojo::JSON->false,
        api      => Mojo::JSON->true,
      },
      {
        url      => "/inventory/group/:group_id",
        meth     => "GET",
        auth     => Mojo::JSON->true,
        location => "$my_domain/group/:group_id",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/inventory/group/:group_id/children",
        meth     => "GET",
        auth     => Mojo::JSON->true,
        location => "$my_domain/group/:group_id/children",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/group",
        meth     => "POST",
        auth     => Mojo::JSON->true,
        location => "$my_domain/group",
        root     => Mojo::JSON->false,
        api      => Mojo::JSON->true,
      },
      {
        url      => "/group/:group_id",
        meth     => "DELETE",
        auth     => Mojo::JSON->true,
        location => "$my_domain/group/:group_id",
        root     => Mojo::JSON->false,
        api      => Mojo::JSON->true,
      },
    ],
    hooks => {
      consume => [
        {
          plugin   => "dashboard",
          action   => "index",
          location => "$my_domain/mainmenu",
        },
      ],
    },
  };

  my $tx =
    $ua->post( "$rex_io_webui/1.0/plugin/plugin", json => $register_conf );

  $self->render( json => $tx->res->json );
}

sub index {
  my $self = shift;

  my $group =
    $self->rexio->call( "GET", "1.0", "inventory", "group" => $self->param("group_id") )
    ->{data};
  $self->stash("group", $group);
  $self->render();
}

sub index_rows {
  my $self = shift;

  my $entries =
    $self->rexio->call( "GET", "1.0", "inventory", "inventory" => $self->param("group_id") )
    ->{data};

  my @ret;
  for my $entry ( @{$entries} ) {
    push @ret, [ $entry->{id}, $entry->{name}, $entry->{type} ];
  }

  $self->render( json => { ok => Mojo::JSON->true, data => \@ret } );
}

sub index_columns {
  my $self = shift;
  $self->render(
    json => {
      ok   => Mojo::JSON->true,
      data => [
        {
          width => 80,
          name  => "Id",
        },
        {
          name => "Name",
        },
        {
          width => 150,
          name  => "Type",
        },
      ],
    }
  );
}

sub mainmenu {
  my $self = shift;

  my $root =
    $self->rexio->call( "GET", "1.0", "inventory", "group" => "root" )
    ->{data};

  $self->app->log->debug("Got User: " . $self->req->headers->header('X-RexIO-User'));
  $self->app->log->debug("Got Password: " . $self->req->headers->header('X-RexIO-Password'));
  $self->app->log->debug("Got Server: " . $self->req->headers->header('X-RexIO-Server'));

  #my $root = { name => "Root" };

  $self->stash("root", $root);

  my $mainmenu = $self->render_to_string( "main/mainmenu", partial => 1 );
  $self->render( json => { main_menu => $mainmenu } );
}

sub inventory_types {
  my $self = shift;
  $self->render(
    json => {
      ok   => Mojo::JSON->true,
      data => [
        {
          id   => 'inventory/asset/server',
          name => 'Server',
        },
      ]
    }
  );
}

sub create_inventory_asset {
  my $self = shift;
  my $ref  = $self->req->json;

  $self->app->log->debug("Creating new asset:");
  $self->app->log->debug( Dumper($ref) );

  my $ret = $self->rexio->call("POST", "1.0", "inventory", "inventory" => undef, ref => $ref);

  $self->app->log->debug("Got answer from rexio-server:");
  $self->app->log->debug( Dumper($ret) );

  $self->render(
    json => {
      ok => Mojo::JSON->true,
    }
  );
}

1;
