#!/usr/bin/perl

# ----------------------------------------------------------------------
# $Id: Makefile.PL,v 1.2 2003/09/24 12:25:34 dlc Exp $
# ----------------------------------------------------------------------
# Makefile.PL for MySQL::Config.
# Originally created on Tuesday, September 23, 2003.
# ----------------------------------------------------------------------

use strict;

use ExtUtils::MakeMaker;
my (%PREREQ_PM, @EXE_FILES, %clean, %macro, %dist, @AUTHOR, @ABSTRACT);

%PREREQ_PM = (

);

@EXE_FILES = (

);

%clean = (
    FILES => '$(DISTVNAME).tar$(SUFFIX)',
);

%macro = (

);

%dist = (
    PREOP => 'perldoc -t lib/MySQL/Config.pm > README; cpansign -s',
);

if ($] >= 5.00503) {
    @AUTHOR = (AUTHOR => 'darren chamberlain <darren@cpan.org>');
    @ABSTRACT = (ABSTRACT => '');
}
else {
    @AUTHOR = ();
    @ABSTRACT = ();
}

WriteMakefile(
    NAME        => "MySQL::Config",
    VERSION     => "1.03",
    PREREQ_PM   => \%PREREQ_PM,
    EXE_FILES   => \@EXE_FILES,
    clean       => \%clean,
    macro       => \%macro,
    dist        => \%dist,
    @AUTHOR,
    @ABSTRACT,
);

package MY;
use File::Basename qw(basename);

sub libscan {
    my ($self, $file) = @_;
    my $bfile = basename($file);

    return if $bfile =~ /^\.(?:cvs)?ignore$/;
    return if $bfile =~ /\.swp$/;

    return $self->SUPER::libscan($file);
}
