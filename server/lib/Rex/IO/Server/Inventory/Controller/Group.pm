#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::IO::Server::Inventory::Controller::Group;

use Mojo::Base 'Mojolicious::Controller';

sub read {
  my $self = shift;

  my $group_id = $self->param("group_id");

  $self->app->log->debug("Want to read group: $group_id");

  my $group_o = $self->db->resultset("Group")->find($group_id);
  if ( !$group_o ) {
    return $self->render(
      json   => { ok => Mojo::JSON->true, message => "Group not found." },
      status => 404
    );
  }

  $self->render(
    json => { ok => Mojo::JSON->true, data => $group_o->all_data } );
}

sub read_root {
  my $self = shift;

  $self->app->log->debug("Want to read group root");

  my $group_o = $self->db->resultset("Group")->find(1);
  if ( !$group_o ) {
    return $self->render(
      json   => { ok => Mojo::JSON->true, message => "root not found." },
      status => 404
    );
  }

  $self->render(
    json => { ok => Mojo::JSON->true, data => $group_o->all_data } );
}

sub get_children {
  my ($self) = @_;
  my $group_o = $self->db->resultset("Group")->find($self->param("group_id"));
  
  my $rs = $group_o->children;
  my @ret;
  while(my $child = $rs->next) {
    push @ret, $child->all_data;
  }
  
  $self->render(json => { ok => Mojo::JSON->true, data => \@ret });
}

sub create {
  my ($self) = @_;
  my $ref = $self->req->json;
  
  if(! exists $ref->{parent_id}) {
    return $self->render(json => {ok => Mojo::JSON->false, error => "Missing parent_id", }, status => 500);
  }
  
  my $parent_o = $self->db->resultset("Group")->find($ref->{parent_id});

  if(! $parent_o) {
    return $self->render(json => {ok => Mojo::JSON->false, error => "Parent not found.", }, status => 404);
  }

  delete $ref->{parent_id};

  eval {
    $parent_o->add_to_children($ref);
    1;
  } or do {
    return $self->render(json => {ok => Mojo::JSON->false, error => $@}, 500);
  };
  
  $self->render(json => {ok => Mojo::JSON->true});
}

sub remove {}
sub update {}

1;