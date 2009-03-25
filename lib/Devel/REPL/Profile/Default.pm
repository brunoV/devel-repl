package Devel::REPL::Profile::Default;

use Moose;
use namespace::clean -except => [ 'meta' ];

with 'Devel::REPL::Profile';

sub plugins {
  qw(Term::ReadLine History LexEnv DDS Packages Commands MultiLine::PPI LoadClass);
}

sub apply_profile {
  my ($self, $repl) = @_;
  $repl->load_plugin($_) for $self->plugins;
}

1;
