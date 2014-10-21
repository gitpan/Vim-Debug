# ABSTRACT: Vim::Debug Perl interface.
package Vim::Debug::Perl;
BEGIN {
  $Vim::Debug::Perl::VERSION = '0.6';
}

use strict;
use warnings;
use parent qw(Vim::Debug);
use Carp;

$ENV{"PERL5DB"}     = 'BEGIN {require "perl5db.pl";}';
$ENV{"PERLDB_OPTS"} = "ornaments=''";


# used to parse debugger 
our $dpr = '.*  DB<+\d+>+ '; # debugger prompt regex
sub dbgrPromptRegex    { qr/$dpr/ }
sub compilerErrorRegex { qr/aborted due to compilation error${dpr}/ }
sub runtimeErrorRegex  { qr/ at .* line \d+${dpr}/ }
sub appExitedRegex     { qr/((\/perl5db.pl:)|(Use .* to quit or .* to restart)|(\' to quit or \`R\' to restart))${dpr}/ }

sub parseOutput {
   my $self   = shift or confess;
   my $output = shift or confess;

   {
      # See .../t/VD_DI_Perl.t for test cases.
      my $filePath;
      my $lineNumber;
      $output =~ /
         ^ \w+ ::
         (?: \w+ :: )*
         (?: CODE \( 0x \w+ \) | \w+ )?
         \(
            (?: .* \x20 )?
            ( .+ ) : ( \d+ )
         \):
      /xm;
      $self->filePath($1)   if defined $1;
      $self->lineNumber($2) if defined $2;
   }

   {
      if ($output =~ /^x .*\n/m) {
         $output =~ s/^x .*\n//m; # remove first line
         $output =~ s/\n.*$//m; # remove last line
         $self->value($output);
      }
   }

   return undef;
}

sub next                { return [ 'n'                  ] }
sub step                { return [ 's'                  ] }
sub cont                { return [ 'c'                  ] }
sub break               { return [ "f $_[2]", "b $_[1]" ] }
sub clear               { return [ "f $_[2]", "B $_[1]" ] }
sub clearAll            { return [ "B *"                ] }
sub print               { return [ "x $_[1]"            ] }
sub command             { return [ $_[1]                ] }
sub restart             { return [ "R"                  ] }
sub quit                { return [ "q"                  ] }


1;

__END__
=pod

=head1 NAME

Vim::Debug::Perl - Vim::Debug Perl interface.

=head1 VERSION

version 0.6

=head1 AUTHOR

Eric Johnson <vimdebug at iijo dot org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Eric Johnson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

