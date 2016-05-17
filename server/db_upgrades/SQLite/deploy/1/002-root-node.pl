return sub {
  my ($schema, $versions) = @_;

  $schema->resultset("Group")->create({ name => "root" });
};
