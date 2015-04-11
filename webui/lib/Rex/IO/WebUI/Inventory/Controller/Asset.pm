package Rex::IO::WebUI::Inventory::Controller::Asset;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub _get_asset {
  my $self = shift;
  my $asset_id = shift;

  my $asset = $self->rexio->call( "GET", "1.0", "inventory",
    "inventory" => $asset_id );
  $self->app->log->debug( Dumper($asset) );

  if ( !$asset->{data} || ( exists $asset->{data} && !$asset->{data}->[0] ) ) {
    $self->app->log->error(
      "Asset $asset_id not found." );
    $self->render( text => "Not found.", status => 404 );
    return 0;
  }

  $self->stash( asset => $asset->{data}->[0] );
  return $asset;
}

sub index {
  my $self = shift;

  my $asset = $self->_get_asset($self->param("asset_id")) || return;

  my $type = $asset->{data}->[0]->{type};
  $self->app->log->debug("Rendering asset_type: $type");

  $self->render("asset/index_$type");
}

sub asset_tabs {
  my $self = shift;

  my $asset = $self->_get_asset($self->param("asset_id")) || return;

  my $type = $asset->{data}->[0]->{type};
  $self->app->log->debug("Rendering tabs for asset_type: $type");

  my $ret = {
    tabs => [
      {
        id    => "asset-main",
        title => "Information",
      },
    ],
    content => {
      "asset-main" => $self->render_to_string(
        "asset/$type/tabs/information", partial => 1
      )
    },
  };

  $self->render( json => { ok => Mojo::JSON->true, data => $ret } );
}

1;
