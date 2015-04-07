package Rex::IO::Server::Inventory;
use Mojo::Base 'Mojolicious';

use Rex::IO::Server::Inventory::Schema;

has schema => sub {
  my ($self) = @_;

  my $dsn =
      "dbi:Pg:"
    . "database="
    . $self->config->{database}->{schema} . ";" . "host="
    . $self->config->{database}->{host};

  return Rex::IO::Server::Inventory::Schema->connect(
    $dsn,
    $self->config->{database}->{username},
    $self->config->{database}->{password},
    { mysql_enable_utf8 => 1 }
  );
};

# This method will run once at server start
sub startup {
  my $self = shift;

  my $ua = $self->ua;

  $self->helper( db => sub { $self->app->schema } );

  #######################################################################
  # Load configuration
  #######################################################################
  my @cfg = (
    "inventory_server.conf",
    "/etc/rex/io/inventory_server.conf",
    "/usr/local/etc/rex/io/inventory_server.conf",
  );
  my $cfg;
  for my $file (@cfg) {
    if ( -f $file ) {
      $cfg = $file;
      last;
    }
  }

  #######################################################################
  # Load plugins
  #######################################################################
  $self->plugin( "Config", file => $cfg );

  #######################################################################
  # routes
  #######################################################################
  my $r = $self->routes;
  $r->get('/inventory')->to('main#read_all');
  $r->get('/inventory/:hw_id')->to('main#read');
  $r->post('/inventory')->to('main#create');
  $r->post('/register')->to('main#register_plugin');
}

1;
