use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => "MySQL::Config",
    VERSION_FROM => "lib/MySQL/Config.pm",
    clean        => { FILES => 'MySQL-Config-$(VERSION).tar.gz' },
);
