package Rex::IO::WebUI::Inventory::Controller::Group;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub get_children {
  my ($self) = @_;
  
  my $children =
  $self->rexio->call( "GET", "1.0", "inventory", "group" => $self->param("group_id"), "children" => undef )
  ->{data};

  for (@{ $children }) {
    $_->{url} = "/inventory/group/$_->{id}/children";
  }

  $self->render(json => $children);
}

sub get_group {
  my ($self) = @_;
  
  my $group =
  $self->rexio->call( "GET", "1.0", "inventory", "group" => $self->param("group_id") )
  ->{data};
  
  $group->{url} = "/inventory/group/$group->{id}/children";
  
  $self->app->log->debug(Dumper($group));

  $self->render(json => $group);
}


1;