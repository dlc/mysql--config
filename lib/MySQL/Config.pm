package MySQL::Config;

use strict;
use base qw(Exporter);
use vars qw($VERSION $GLOBAL_CNF @EXPORT @EXPORT_OK);

use Carp qw(carp);

$VERSION    = sprintf "%d.%02d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/;
$GLOBAL_CNF = "/etc/%s.cnf" unless defined $GLOBAL_CNF;
@EXPORT     = qw(load_defaults);
@EXPORT_OK  = qw(parse_defaults);

# ======================================================================
#                        --- Public Functions ---
# ======================================================================

sub load_defaults {
    my ($conf_file, $groups, $argc, $argv) = @_;
    my ($user_cnf, $ini, $field);
    $ini = { };

    # ------------------------------------------------------------------
    # Sanity checking:
    #   # $conf_file should be a string, defaults to "my"
    #   * $groups should be a ref to an array
    #   * $argc should be a ref to a scalar
    #   * $argv should be a ref to an array
    # ------------------------------------------------------------------
    # This silliness is undocumented; please don't rely on it!
    unless (@_ == 4) {
        $argv      = $argc;
        $argc      = $groups;
        $groups    = $conf_file;
        $conf_file = "my";
    }

    $groups = [ $groups ]
        unless ref $groups eq 'ARRAY';

    if (defined $argc) {
        $argc = \$argc
            unless ref $argc eq 'SCALAR';
    } else {
        $argc = \(my $i = 0);
    }

    $argv = [ $argv ]
        unless ref $argv eq 'ARRAY';

    $user_cnf = "$ENV{HOME}/.$conf_file.cnf";

    # ------------------------------------------------------------------
    # Parse the global config and user's config
    # ------------------------------------------------------------------
    _parse($ini, sprintf $GLOBAL_CNF, $conf_file);
    _parse($ini, $user_cnf);

    # ------------------------------------------------------------------
    # Pull out the appropriate pieces, based on @$groups
    # ------------------------------------------------------------------
    @$groups = keys %$ini unless @$groups;

    for $field (@$groups) {
        my @keys = reverse keys %{ $ini->{ $field } };
        for (@keys) {
            unshift @$argv, 
                sprintf "--%s=%s", $_, $ini->{ $field }->{ $_ };
            $$argc++;
        }
    }

    1;
}

sub parse_defaults {
    my ($conf_file, $groups) = @_;
    my ($count, $argv, %ini);
    $argv = [ ];

    unless (@_ == 2) {
        $groups = $conf_file;
        $conf_file = "my";
    }

    load_defaults($conf_file, $groups, \$count, $argv);

    for (@$argv) {
        /^--(.*)=(.*)$/
            and $ini{ $1 } = $2;
    }

    return wantarray ? %ini : \%ini;
}

# ======================================================================
#                        --- Private Functions ---
# ======================================================================

# ----------------------------------------------------------------------
# _parse($file)
#
# Parses an ini-style file
# ----------------------------------------------------------------------
sub _parse {
    my $ini = shift;
    my $file = shift;
    my $current;
    local ($_, *INI);

    return { } unless -f $file && -r _;

    $ini ||= { };
    unless (open INI, $file) {
        carp "Couldn't oprn $file: $!";
        return { };
    }
    while (<INI>) {
        s/[;#].*$//;
        s/^\s*//;
        s/\s*$//;

        next unless length;

        /^\s*\[(.*)\]\s*$/
            and $current = $1, next;

        my ($n, $v) = split /\s*=\s*/;
        $v = qq("$v") if $v =~ /\s/;

        $ini->{ $current }->{ $n } = $v;
    }

    unless (close INI) {
        carp "Couldn't close $file: $!";
    }

    return $ini;
}

1;

__END__

=head1 NAME

MySQL::Config - Parse and utilize MySQL's /etc/my.cnf and ~/.my.cnf files

=head1 SYNOPSIS

    use MySQL::Config;

    my @groups = qw(client myclient);
    my $argc = 0;
    my @argv = ();

    load_defaults "my", @groups, $argc, @argv;

=head1 DESCRIPTION

MySQL::Config emulates the load_defaults() function from mysqlclient.
Just like load_defaults(), it returns a list primed to be passed to
getopt_long(), a.k.a. Getopt::Long.  load_defaults takes 4 arguments:
a string denoting the name of the config file (which should generally
be "my"); an array of groups which should be returned; a scalar that
will hold the total number of parsed elements; and an array that will
hold the final versions of the extracted name, value pairs.  This
final array will be in a format suitable for processing with
Getopt::Long:

    --user=username
    --password=password

and so on.

load_defaults() has an un-Perlish interface, mostly because it is
exactly the same signature as the version from the C API.  There is
also a function, not exported by default, called parse_defaults(),
which returns a hash of parsed (name, value) pairs (or a hashref
in scalar context):

    use MySQL::Config qw(parse_defaults);

    my %cfg = parse_defaults("my", [ qw(client myclient) ]);

%cfg looks like:

    %cfg = (
        "user" => "username",
        "password" => "password",
    )

and so on.  This might be a more natural interface for some programs;
however, load_defaults() is more true to the original.

=head1 USING SOMETHING OTHER THAN "my" AS THE FIRST STRING

This string controls the name of the configuration file; the names
work out to, basically:

    ~/.${cfg_name}.cnf

and

    /etc/${cnf_name}.cnf

If you are using this module for mysql clients, then this should
probably remain my.  Otherwise, you are free to mangle this however
you choose.

    $ini = parse_defaults("your", [ "foo" ]);

=head1 BUGS / KNOWN ISSUES

The C version of load_defaults() returns elements in the order in
which they are defined in the file; this version returns them in hash
order, with duplicates removed.

=head1 VERSION

$Revision: 1.1 $

=head1 AUTHOR

darren chamberlain E<lt>darren@cpan.orgE<gt>
