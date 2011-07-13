package Template::Plugin::Macboogi;
# ABSTRACT: Template::Plugin::Macboogi
use Moose;
use namespace::autoclean;

has 'foo' => (
    is => 'ro',
    isa => 'Str',
    require => 1
);

=head1 METHODS

=head2 method

method

=cut

__PACKAGE__->meta->make_immutable;

=head1 SYNOPSIS

...

=head1 DESCRIPTION

...

=cut

1;
