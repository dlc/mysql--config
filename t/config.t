#!/usr/bin/perl

use strict;

use Cwd;
use File::Spec;
use MySQL::Config qw(load_defaults parse_defaults);
use Test;

BEGIN { plan tests => 10 }

ok(1);  # loaded module

$MySQL::Config::GLOBAL_CNF = File::Spec->catfile(cwd, "my.cnf");

local *CNF;
open CNF, ">$MySQL::Config::GLOBAL_CNF"
    or ok(0, 1, " Couldn't open $MySQL::Config::GLOBAL_CNF: $!");
print CNF <<__CNF__;
[foo]
bar=baz
quux = hoopy frood

[frobniz]
hehe= haha

__CNF__

close CNF
    or ok(0, 1, " Couldn't close $MySQL::Config::GLOBAL_CNF: $!");

END { ok(unlink $MySQL::Config::GLOBAL_CNF, 1, "Can't unlink $MySQL::Config::GLOBAL_CNF: $!") }

my @groups = qw(foo frobniz);
my $count = 0;
my @argv = ();

load_defaults("my", \@groups, \$count, \@argv);
@argv = sort @argv;

# Got right number of elements
ok($count, 3);

# same test, basically
ok(scalar @argv, 3);

ok($argv[0], '--bar=baz');
ok($argv[1], '--hehe=haha');
ok($argv[2], '--quux="hoopy frood"');

my %ini = parse_defaults("my", [ qw(foo frobniz) ]);

ok($ini{'bar'}, "baz");
ok($ini{'hehe'}, "haha");
ok($ini{'quux'}, '"hoopy frood"');


