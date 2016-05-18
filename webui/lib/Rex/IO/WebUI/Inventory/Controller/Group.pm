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

sub create_group {
  my ($self) = @_;

  my $ret = $self->rexio->call( "POST", "1.0", "inventory", "group" => undef, ref => $self->req->json->{data} );
  $self->render(json => $ret);
}

sub remove_group {
  my ($self) = @_;

  my $ret = $self->rexio->call( "DELETE", "1.0", "inventory", "group" => $self->param("group_id"));
  $self->render(json => $ret);
}

1;