# ABSTRACT: A base class for Vim::Debug modules


package Vim::Debug;
BEGIN {
  $Vim::Debug::VERSION = '0.6';
}

use strict;
use warnings;
use Class::Accessor::Fast;
use base qw(Class::Accessor::Fast);

use Carp;
use IO::Pty;
use IPC::Run;

$| = 1;

my $READ;
my $WRITE;

my $COMPILER_ERROR = "compiler error";
my $RUNTIME_ERROR  = "runtime error";
my $APP_EXITED     = "application exited";
my $DBGR_READY     = "debugger ready";

__PACKAGE__->mk_accessors(
    qw(dbgrCmd timer dbgr stop shutdown lineNumber filePath value translatedInput READ WRITE
       debug original status oldOut)
);


sub start {
   my $self = shift or confess;

   # initialize some variables
   $self->original('');
   $self->out('');
   $self->value('');
   $self->oldOut('');
   $self->translatedInput([]);
   $self->debug(0);
   $self->timer(IPC::Run::timeout(10, exception => 'timed out'));

   # spawn debugger process
   $self->dbgr(
      IPC::Run::start(
         $self->dbgrCmd, 
         '<pty<', \$WRITE,
         '>pty>', \$READ,
         $self->timer
      )
   );
   return undef;
}

sub write {
   my $self = shift or confess;
   my $c    = shift or confess;
   $self->value('');
   $self->stop(0);
   $WRITE .= "$c\n";
   return;
}

sub read {
   my $self = shift or confess;
   $| = 1;

   my $dbgrPromptRegex    = $self->dbgrPromptRegex;
   my $compilerErrorRegex = $self->compilerErrorRegex;
   my $runtimeErrorRegex  = $self->runtimeErrorRegex;
   my $appExitedRegex     = $self->appExitedRegex;

   $self->timer->reset();
   eval { $self->dbgr->pump_nb() };
   my $out = $READ;

   if ($@ =~ /process ended prematurely/) {
       print "::read(): process ended prematurely\n" if $self->debug;
       undef $@;
       return 1;
   }
   elsif ($@) {
       die $@;
   }

   if ($self->stop) {
       print "::read(): stopping\n" if $self->debug;
       $self->dbgr->signal("INT");
       $self->timer->reset();
       $self->dbgr->pump() until ($READ =~ /$dbgrPromptRegex/    || 
                                  $READ =~ /$compilerErrorRegex/ || 
                                  $READ =~ /$runtimeErrorRegex/  || 
                                  $READ =~ /$appExitedRegex/); 
       $out = $READ;
   }

   $self->out($out);

   if    ($self->out =~ $dbgrPromptRegex)    { $self->status($DBGR_READY)     }
   elsif ($self->out =~ $compilerErrorRegex) { $self->status($COMPILER_ERROR) }
   elsif ($self->out =~ $runtimeErrorRegex)  { $self->status($RUNTIME_ERROR)  }
   elsif ($self->out =~ $appExitedRegex)     { $self->status($APP_EXITED)     }
   else                                      { return 0                       }

   $self->original($out);
   $self->parseOutput($self->out);

   return 1;
}

sub out {
   my $self = shift or confess;
   my $out = '';

   if (@_) {
      $out = shift;

      my $originalLen = length $self->original;
      $out = substr($out, $originalLen);
        
      # vim is not displaying newline characters correctly for some reason.
      # this localizes the newlines.
      $out =~ s/(?:\015{1,2}\012|\015|\012)/\n/sg;

      # save
      $self->{out} = $out;
   }

   return $self->{out};
}


1;

__END__
=pod

=head1 NAME

Vim::Debug - A base class for Vim::Debug modules

=head1 VERSION

version 0.6

=head1 SYNOPSIS

   package Vim::Debug;

   use strict;
   use warnings;
   use base qw(Vim::Debug);

   sub start {
      my $self = shift or confess;
      my $path               = shift or die;
      my @commandLineOptions = @_;

      # this regexe aids in parsing debugger output.  it is required.
      $self->dbgrPromptRegex($dbgrPromptRegex);

      $self->SUPER::startDebugger("perl -d $path @commandLineOptions");
      return undef;
   }

   # 'n' is the command accepted by your language's debugger
   sub next { return 'n' }
   sub step { return 's' }
   sub cont { return 'c' }
   # ...etc

=head1 DESCRIPTION

This is a base class for developers wanting to add support to vimdebug for
their language. 

=head2 read

Returns 1 when done
Returns 0 if its not done

=head2 out($out)

Remove ornaments (like <CTL-M> or irrelevant error messages or whatever) from
text. 

Returns $out cleansed

=head2 lineNumber($number)

If $number parameter is used, the lineNumber class attribute is set using that
value.  If no parameters are passed, the current value of the lineNumber class
attribute is returned.

=head2 filePath($path)

If $path parameter is used, the filePath class attribute is set using that
value.  If no parameters are passed, the current value of the filePath class
attribute is returned.

=head2 dbgrPromptRegex($regex)

If $regex parameter is used, the dbgrPromptRegex class attribute is set using that
value.  If no parameters are passed, the current value of the dbgrPromptRegex class
attribute is returned.

=head1 SEE ALSO

L<Devel::ebug>, L<perldebguts>

=head1 AUTHOR

Eric Johnson, cpan at iijo : :dot: : org

=head1 COPYRIGHT

Copyright (C) 2003 - 3090, Eric Johnson

This module is GPL.

=head1 AUTHOR

Eric Johnson <vimdebug at iijo dot org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Eric Johnson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

