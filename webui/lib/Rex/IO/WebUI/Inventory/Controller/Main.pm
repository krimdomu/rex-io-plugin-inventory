package Rex::IO::WebUI::Inventory::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';

sub register_plugin {
  my $self         = shift;
  my $rex_io_webui = $self->config->{rex_io}->{webui};
  my $my_domain    = $self->config->{rex_io}->{self};
  my $ua           = $self->ua;

  my $register_conf = {
    name    => "inventory",
    methods => [
      {
        url      => "/inventory",
        meth     => "GET",
        auth     => Mojo::JSON->true,
        location => "$my_domain/inventory",
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
        url      => "/inventory/dt/rows",
        meth     => "GET",
        auth     => Mojo::JSON->true,
        location => "$my_domain/inventory/dt/rows",
        root     => Mojo::JSON->true,
      },
      {
        url      => "/js/inventory.js",
        meth     => "GET",
        auth     => Mojo::JSON->false,
        location => "$my_domain/js/inventory.js",
        root     => Mojo::JSON->true,
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
  $self->render();
}

sub index_rows {
  my $self = shift;
  my $entries =
    $self->rexio->call( "GET", "1.0", "inventory", "inventory" => undef )
    ->{data};

  my @ret;
  for my $entry ( @{$entries} ) {
    push @ret, [ $entry->{id}, $entry->{name}, ];
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
      ],
    }
  );
}

sub mainmenu {
  my $self = shift;
  my $mainmenu = $self->render_to_string( "main/mainmenu", partial => 1 );
  $self->render( json => { main_menu => $mainmenu } );
}

1;
