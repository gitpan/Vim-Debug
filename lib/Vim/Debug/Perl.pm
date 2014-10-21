# ABSTRACT: Perl debugger interface.

package Vim::Debug::Perl;

our $VERSION = '0.904'; # VERSION

use Moose::Role;

$ENV{"PERL5DB"}     = 'BEGIN {require "perl5db.pl";}';
$ENV{"PERLDB_OPTS"} = "ornaments=''";

sub next     { 'n' }
sub step     { 's' }
sub stepout  { 'r' }
sub cont     { 'c' }
sub break    { "f $_[2]", "b $_[1]" }
sub clear    { "f $_[2]", "B $_[1]" }
sub clearAll { 'B *' }
sub print    { "x $_[1]" }
sub command  { $_[1] }
sub restart  { 'R' }
sub quit     { 'q' }

    # Debugger prompt regex.
my $dpr = qr/  DB<+\d+>+ \z/s;

sub prompted_and_parsed {
    my ($self, $str) = @_;

        # If we don't have the debugger prompt string, we're not ready
        # to parse.
    return unless $str =~ s/$dpr//;

    $self->parseOutput($str);
    return 1;
}

sub parseOutput {
    my ($self, $str) = @_;

    my $file;
    my $line;
    my $status;

    if (
        $str  =~ /
            ^ Execution\ of\ .*?\ aborted\ due\ to\ compilation\ errors\.
            \n \ at\ (.*?)\ line\ (\d+)\.
        /xm
    ) {
        $status = $self->s_compilerError;
        $file = $1;
        $line = $2;
    }
    elsif (
        $str =~ /
            (?:
                (?: \/perl5db.pl: ) |
                (?: Use\ .*\ to\ quit\ or\ .*\ to\ restart ) |
                (?: '\ to\ quit\ or\ `R'\ to\ restart )
            )
        /sx
    ) {
        $status = $self->s_appExited;
    }
    else {
        $status = $self->s_dbgrReady;
        $str =~ /
            ^ \w+ ::
            (?: \w+ :: )*
            (?: CODE \( 0x \w+ \) | \w+ )?
            \(
                (?: .* \x20 )?
                ( .+ ) : ( \d+ )
            \):
        /xm;
        $file = $1;
        $line = $2;

            # Remove first and last lines when 'x' was the command,
            # the text remaining being the value that was requested.
        if ($str =~ /^x .*\n/m) {
            $str =~ s/^x .*\n//m;
            $str =~ s/\n.*$//m;
            $self->value($str);
        }
    }
    $self->file($file) if $file;
    $self->line($line) if $line;
    $self->status($status);
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Vim::Debug::Perl - Perl debugger interface.

=head1 DESCRIPTION

If you are new to Vim::Debug please read the user manual,
L<Vim::Debug::Manual>, first.

This module is a role that is dynamically applied to an Vim::Debug instance.
L<Vim::Debug> represents a debugger.  This module only handles the Perl
specific bits.  Theoretically there might be a Ruby or Python role someday.

=head1 METHODS

=head2 prompted_and_parsed($output)

If the $output string doesn't end with the debugger prompt string,
this method will return false, because that means that there should be
more debugger output coming.

Otherwise, $output will be parsed and the object's 'file', 'line',
'value', and 'status' attributes will be set and the method will
return true.

=head1 FUNCTIONS

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

=head1 TRANSLATION CLASS ATTRIBUTES

These attributes are used to convert commands from the communication
protocol to commands the Perl debugger can recognize.  For example,
the communication protocol uses the keyword 'next' while the Perl
debugger uses 'n'.

=head1 AUTHOR

Eric Johnson <kablamo at iijo dot nospamthanks dot org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Eric Johnson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
