#!/usr/bin/perl

package Devel::REPL::Plugin::CompletionDriver::Turtles;
use Devel::REPL::Plugin;

use namespace::clean -except => [ "meta" ];

around complete => sub {
  my $orig = shift;
  my ($self, $text, $document) = @_;

  my $prefix = $self->default_command_prefix;
  my $line_re = qr/^($prefix)(\w+)/;

  my @orig = $self->$orig($text, $document);

  if ( my ( $pre, $method ) = ( $text =~ $line_re ) ) {
    my $filter = qr/^\Q$method/;
    return (
      @orig,
      (
        map { "$pre$_" }
        grep { $_ =~ $filter }
        map { /^expr?_command_(\w+)/ ? $1 : () }
        map { $_->{name} }
        $self->meta->compute_all_applicable_methods
      ),
    );
  } else {
    return @orig;
  }
};

__PACKAGE__

__END__

=head1 NAME

Devel::REPL::Plugin::CompletionDriver::Turtles - Complete Turtles-based commands

=head1 AUTHOR

Yuval Kogman E<lt>nothingmuch@woobling.orgE<gt>

=cut

