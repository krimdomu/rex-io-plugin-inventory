package Rex::IO::WebUI::Inventory;
use Mojo::Base 'Mojolicious';
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

# This method will run once at server start
sub startup {
  my $self = shift;

  $self->plugin("Rex::IO::WebUI::Inventory::Mojolicious::Plugin::RexIOServer");

  #######################################################################
  # Routes
  #######################################################################
  my $r = $self->routes;

  $r->get('/mainmenu')->to('main#mainmenu');
  $r->get('/inventory')->to('main#index');
  $r->get('/inventory/asset/:asset_id')->to('asset#index');
  $r->get('/inventory/asset/:asset_id/tabs')->to('asset#asset_tabs');

  $r->get('/inventory/dt/columns')->to('main#index_columns');
  $r->get('/inventory/dt/rows')->to('main#index_rows');
  $r->get('/inventory/types')->to('main#inventory_types');
  $r->post('/register')->to('main#register_plugin');

  $r->post('/inventory/asset')->to('main#create_inventory_asset');

  #######################################################################
  # Load configuration
  #######################################################################
  my @cfg = (
    "inventory_webui.conf",
    "/etc/rex/io/inventory_webui.conf",
    "/usr/local/etc/rex/io/inventory_webui.conf",
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
  # for the package
  #######################################################################

  # Switch to installable home directory
  $self->home->parse( catdir( dirname(__FILE__), 'Inventory' ) );

  # Switch to installable "public" directory
  $self->static->paths->[0] = $self->home->rel_dir('public');

  # Switch to installable "templates" directory
  $self->renderer->paths->[0] = $self->home->rel_dir('templates');
}

1;
