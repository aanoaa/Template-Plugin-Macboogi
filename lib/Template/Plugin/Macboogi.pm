package Template::Plugin::Macboogi;
# ABSTRACT: Template::Plugin::Macboogi
use strict;
use utf8;
use Const::Fast;
use Encode qw/decode_utf8 encode_utf8/;
use Lingua::KO::Hangul::Util qw(:all);
use vars qw($VERSION);
$VERSION = 0.01;

require Template::Plugin;
use base qw(Template::Plugin);

use vars qw($FILTER_NAME);
$FILTER_NAME = 'macboogi';

const my $JONGSUNG_BEGIN    => 0x11A8;
const my $JONGSUNG_END      => 0x11FF;
const my $JONGSUNG_DIGEUG   => 0x11AE; # ㄷ
const my $JONGSUNG_BIEUP    => 0x11B8; # ㅂ
const my $JONGSUNG_JIEUT    => 0x11BD; # ㅈ
const my $SELLABLE_BEGIN    => 0x3131;
const my $INTERVAL          => $SELLABLE_BEGIN - $JONGSUNG_BEGIN;

sub new {
    my($self, $context, @args) = @_;
    my $name = $args[0] || $FILTER_NAME;
    $context->define_filter($name, \&commify, 0);
    $context->define_filter($name, \&macboogify, 0);
    return $self;
}

sub macboogify {
    #my $input = decode_utf8(uc shift);
    my $input = uc shift;
    my @chars = split //, $input;
    my @mac_chars;
    for my $char (@chars) {
        my $ord = ord $char;
        if ($ord >= 65 && $ord <= 90) {
            push @mac_chars, $char;
            next;
        }

        my @jamo = split //, decomposeSyllable($char);
        for (@jamo) {
            my $code = unpack 'U*', $_;
            if ($code >= $JONGSUNG_BEGIN && $code <= $JONGSUNG_DIGEUG) {
                $code += $INTERVAL;
            } elsif ($code > $JONGSUNG_DIGEUG && $code <= $JONGSUNG_BIEUP) {
                $code += $INTERVAL + 1;
            } elsif ($code > $JONGSUNG_BIEUP && $code <= $JONGSUNG_JIEUT) {
                $code += $INTERVAL + 2;
            } elsif ($code > $JONGSUNG_JIEUT && $code <= $JONGSUNG_END) {
                $code += $INTERVAL + 3;
            }

            $_ = pack 'U*', $code;
        }

        push @mac_chars, composeSyllable(join '', @jamo);
    }

    my $chars = join '', @mac_chars;
    $chars =~ s/^use /use /i;
    #return encode_utf8($chars);
    return $chars;
}

1;
__END__

=head1 NAME

Template::Plugin::Macboogi - TT Plugin to commify numbers

=head1 SYNOPSIS

  [% USE Macboogi %]

  [% FILTER macboogi -%]
  use catalyst;
  [%- END %]

  # Output:
  # use CATALYST;

  [% '안녕하세요' | macboogi %]

  # Output:
  # 아ㄴ녀ㅇ하세요

=head1 DESCRIPTION

Template::Plugin::Macboogi is a plugin for TT, which allows you to
macboogify your numbers in templates. This would be especially useful for
`aero`.

=head1 SEE ALSO

L<Template>

=cut
