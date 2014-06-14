package Pod::Weaver::Plugin::Exec;

# ABSTRACT: include output of commands in your pod

use Moose;
with 'Pod::Weaver::Role::Dialect';

sub translate_dialect {
   Pod::Elemental::Transformer::Exec->new->transform_node($_[1])
}

package
   Pod::Elemental::Transformer::Exec {

   use Moose;
   with 'Pod::Elemental::Transformer';

   use Capture::Tiny 'capture_stdout';
   use Moose::Autobox;
   use namespace::clean;

   sub transform_node {
      my ($self, $node) = @_;
      my $children = $node->children;

    PASS: for (my $i = 0 ; $i < $children->length ; $i++) {
         my $para = $children->[$i];
         next
           unless $para->isa('Pod::Elemental::Element::Pod5::Region')
           and !$para->is_pod
           and $para->format_name eq 'exec';

         confess "exec transformer expects exec region to contain 1 Data para"
           unless $para->children->length == 1
           and $para->children->[0]->isa('Pod::Elemental::Element::Pod5::Data');

         chomp(my $command = $para->children->[0]->content);
         my $out = capture_stdout { system($command) };
         $out = join "\n", map " $_", split /\n/, $out;

         my $new_doc =
           Pod::Elemental->read_string("\n\n=pod\n\n$out\n\n");
         Pod::Elemental::Transformer::Pod5->transform_node($new_doc);
         $new_doc->children->shift
           while $new_doc->children->[0]
           ->isa('Pod::Elemental::Element::Pod5::Nonpod');

         splice @$children, $i, 1, $new_doc->children->flatten;
      }

      return $node;
   }
}

1;

__END__

=pod

=head1 SYNOPSIS

In your F<weaver.ini>:

 [@Default]
 [-Exec]

In the pod of one of your modules:

 =head1 EXAMPLE OUTPUT

 =for exec
 perl maint/script.pl

=head1 DESCRIPTION

This is a L<Pod::Weaver> plugin that will take the output of a command and
insert it as literal data into the pod.

=head1 PERL SUPPORT POLICY

Because this module is geared towards helping release code, as opposed to
helping run code, I only aim at supporting the last 3 releases of Perl.  So for
example, at the time of writing that would be 5.20, 5.18, and 5.16.  As an
author who is developing against Perl and using this to release modules, you can
use either L<perlbrew|http://perlbrew.pl/> or
L<plenv|https://github.com/tokuhirom/plenv> to get a more recent perl to release
from.

Don't bother sending patches to support older versions; I could probably support
5.8 if I wanted, but this is more so that I can continue to use new perl
features.
