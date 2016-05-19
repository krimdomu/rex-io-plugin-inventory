package Rex::IO::WebUI::Inventory::Controller::Asset::Server;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub server_new {
  my $self = shift;
  $self->render("asset/server/server_new");
}

1;