# ABSTRACT: Integrate the Perl debugger with Vim


package Vim::Debug::Manual;

our $VERSION = '0.901'; # VERSION

__END__

=pod

=encoding utf-8

=head1 NAME

Vim::Debug::Manual - Integrate the Perl debugger with Vim

=head1 What is VimDebug?

VimDebug integrates the Perl debugger with Vim, allowing developers to
visually step through their code, examine variables, set or clear
breakpoints, etc.

VimDebug is known to work under Unix/Ubuntu/OSX. It requires Perl 5.FIXME or
later and some CPAN modules may need to be installed.  It also requires Vim
7.FIXME or later that was built with the +signs and +perl extensions.

=head1 How do I install VimDebug?

VimDebug has a Perl component and a Vim component.  To install the Perl
libraries use L<cpanm|https://metacpan.org/module/App::cpanminus>:

    # install cpanm
    curl -L http://cpanmin.us | perl - --sudo App::cpanminus

    # install VimDebug Perl libraries
    cpanm VimDebug

Next, install the Vim component:

    vimdebug-install -d ~/.vim

You may want to replace C<~/.vim> by some other directory that your
Vim recognizes as a runtimepath directory. See Vim's ":help
'runtimepath'" for more information.

=head1 Using VimDebug

Launch Vim and open a file named with a ".pl" extension. Press <F12>
to start the debugger. To change the default Vim key bindings, shown
here, edit VimDebug.vim:

    <F12>      Start the debugger
    <Leader>s/ Start the debugger.  Prompts for command line arguments.
    <F10>      Restart debugger. Break points are ALWAYS saved (for all dbgrs).
    <F11>      Exit the debugger

    <F6>       Next
    <F7>       Step
    <F8>       Continue

    <Leader>b  Set break point on the current line
    <Leader>c  Clear break point on the current line

    <Leader>v  Print the value of the variable under the cursor
    <Leader>v/ Print the value of an expression thats entered

    <Leader>/  Type a command for the debugger to execute and echo the result

=head1 Improving VimDebug

VimDebug is on github: https://github.com/kablamo/VimDebug.git

To do development work on VimDebug, clone its git repo and read
./documentation/DEVELOPER.HOWOTO.

In principle, the VimDebug code can be extended to handle other
debuggers, like the one for Ruby or Python, but that remains to be
done.

Please note that this code is in beta.

=head1 AUTHOR

Eric Johnson <kablamo at iijo dot nospamthanks dot org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Eric Johnson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
