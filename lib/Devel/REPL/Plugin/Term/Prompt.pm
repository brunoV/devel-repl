package Devel::REPL::Plugin::Term::Prompt;
use Devel::REPL::Plugin;

has 'prompt' => (
  is       => 'rw',
  isa      => 'Str',
  default  => sub { '$ ' },
  required => 1,
);

1;
