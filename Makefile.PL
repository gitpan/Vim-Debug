
use strict;
use warnings;

use 5.010;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Perl wrapper around a command line debugger",
  "AUTHOR" => "Eric Johnson <vimdebug at iijo dot org>",
  "BUILD_REQUIRES" => {
    "English" => 0,
    "Net::Telnet" => 0,
    "Test::More" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Vim-Debug",
  "EXE_FILES" => [
    "bin/vdd"
  ],
  "LICENSE" => "perl",
  "NAME" => "Vim::Debug",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Class::Accessor::Fast" => 0,
    "IO::Pty" => 0,
    "IPC::Run" => 0,
    "POE" => 0,
    "VimDebug::Daemon" => 0,
    "base" => 0,
    "feature" => 0,
    "parent" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.8",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



