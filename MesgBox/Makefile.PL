use ExtUtils::MakeMaker ;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'         => 'Tk::MesgBox',
    'VERSION_FROM' => 'MesgBox.pm', # finds $VERSION
    'DISTNAME'     => 'TK-MesgBox',
    ($] >= 5.005 ?
        (
            ABSTRACT => 'Simple Message box with automatic key bindings.',
            AUTHOR   => 'Mark Summerfield <summer@chest.ac.uk>',
        ) : () ),
    'LIBS'         => [''],   # e.g., '-lm'
    'DEFINE'       => '',     # e.g., '-DHAVE_SOMETHING'
    'INC'          => '',     # e.g., '-I/usr/include/other'
    'dist'         => { COMPRESS => "gzip -9", SUFFIX => "gz" }
) ;
