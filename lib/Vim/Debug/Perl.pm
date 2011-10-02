# ABSTRACT: Perl debugger interface.


package Vim::Debug::Perl;
{
  $Vim::Debug::Perl::VERSION = '0.10';
}

use Moose::Role;

$ENV{"PERL5DB"}     = 'BEGIN {require "perl5db.pl";}';
$ENV{"PERLDB_OPTS"} = "ornaments=''";



our $dpr = '.*  DB<+\d+>+ '; # debugger prompt regex
sub dbgrPromptRegex    { qr/$dpr/ }
sub compilerErrorRegex { qr/aborted due to compilation error${dpr}/ }
sub runtimeErrorRegex  { qr/ at .* line \d+${dpr}/ }
sub appExitedRegex     { qr/((\/perl5db.pl:)|(Use .* to quit or .* to restart)|(\' to quit or \`R\' to restart))${dpr}/ }


sub next                { return ( 'n'                  ) }
sub step                { return ( 's'                  ) }
sub cont                { return ( 'c'                  ) }
sub break               { return ( "f $_[2]", "b $_[1]" ) }
sub clear               { return ( "f $_[2]", "B $_[1]" ) }
sub clearAll            { return ( "B *"                ) }
sub print               { return ( "x $_[1]"            ) }
sub command             { return ( $_[1]                ) }
sub restart             { return ( "R"                  ) }
sub quit                { return ( "q"                  ) }


sub parseOutput {
   my $self   = shift or die;
   my $output = shift or die;

   {
      # See .../t/VD_DI_Perl.t for test cases.
      my $file;
      my $line;
      $output =~ /
         ^ \w+ ::
         (?: \w+ :: )*
         (?: CODE \( 0x \w+ \) | \w+ )?
         \(
            (?: .* \x20 )?
            ( .+ ) : ( \d+ )
         \):
      /xm;
      $self->file($1)   if defined $1;
      $self->line($2) if defined $2;
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

1;

__END__
=pod

=head1 NAME

Vim::Debug::Perl - Perl debugger interface.

=head1 VERSION

version 0.10

=head1 DESCRIPTION

If you are new to Vim::Debug please read the user manual,
L<Vim::Debug::Manual>, first.

This module is a role that is dynamically applied to an Vim::Debug instance.
L<Vim::Debug> represents a debugger.  This module only handles the Perl
specific bits.  Theoretically there might be a Ruby or Python role someday.

=head1 DEBUGGER OUTPUT REGEX CLASS ATTRIBUTES

These attributes are used to parse debugger output and are used by Vim::Debug.
They return a regex and ignore all values passed to them.  

=head2 dbgrPromptRegex()

=head2 compilerErrorRegex()

=head2 runtimeErrorRegex()

=head2 appExitedRegex()

=head1 TRANSLATION CLASS ATTRIBUTES

These attributes are used to convert commands from the
communication protocol to commands the Perl debugger can recognize.  For
example, the communication protocol uses the keyword 'next' while the Perl
debugger uses 'n'.

=head2 next()

=head2 step()

=head2 cont()

=head2 break()

=head2 clear()

=head2 clearAll()

=head2 print()

=head2 command()

=head2 restart()

=head2 quit()

=head2 METHODS

=head2 parseOutput($output)

$output is output from the Perl debugger.  This method parses $output and
saves relevant valus to the line, file, and output attributes (these
attributes are defined in Vim::Debug)

Returns undef.

=head1 AUTHOR

Eric Johnson <vimdebug at iijo dot org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Eric Johnson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

