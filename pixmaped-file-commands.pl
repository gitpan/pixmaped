#!/usr/bin/perl -w

# $Id: pixmaped-file-commands.pl,v 1.34 1999/02/28 17:28:42 root Exp $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package file ;


sub new {
    package main ;

    my $first_use = shift ;
    $first_use = ( defined $first_use and $first_use == 1 ) ? 1 : 0 ;

    if( $first_use ) {
        $Opt{GRID_WIDTH}  = $Const{GRID_WIDTH_DEF} ;
        $Opt{GRID_HEIGHT} = $Const{GRID_HEIGHT_DEF} ;
    }
    else {
        &file::prompt_save unless $Global{WROTE_IMAGE} ;
        &options::options ;
    }

    &grid::create ;
    &file::new_image ;

    $Global{WROTE_IMAGE} = 1 ;

    $Win->title( $Global{FILENAME} . '  Pixmaped' ) ;
}


sub new_image {
    package main ;

    $Global{FILENAME} = $Const{FILENAME} . $Global{FILENAME_INDEX}++ .
                        $Global{FILE_SUFFIX} ;
    my $xpm           = basename( $Global{FILENAME} ) ;
    $xpm =~ s/[- .]/_/go ;

    %Image              = () ;

    ${$Image{LINES}}[0] = "/* XPM */" ;
    ${$Image{LINES}}[1] = "/* \$Id\$ */" ;
    ${$Image{LINES}}[2] = "static char * $xpm" . "[] = {" ;
    ${$Image{LINES}}[3] = '"0 0 0 0"' ;

    $Image{WIDTH}       = $Opt{GRID_WIDTH} ;
    $Image{HEIGHT}      = $Opt{GRID_HEIGHT} ;
    $Image{COLOURS}     = 0 ;
    $Image{CPP}         = 1 ;
    $Image{HOTX}        = 0 ;
    $Image{HOTY}        = 0 ;
    %{$Image{PALETTE}}  = () ;

    @Undo = () unless $Opt{UNDO_AFTER_SAVE} ;
}


sub open {
    package main ;

    &file::prompt_save unless $Global{WROTE_IMAGE} ;

    shift if ref $_[0] ;
    my $filename = shift ;

    if( defined $filename and $filename =~ /^([1-9])$/o ) {
        $filename = $Opt{"LAST_FILE_$1"} ;
        $filename = '' if $filename eq '(none)' ;
    }

    if( not $filename ) {
        &cursor( 1, 'clock' ) ;
        $Opt{DIR}    = &abs_path( $Opt{DIR} ) ;

        my $dialog   = $Win->FileSelect( 
                        -directory => $Opt{DIR},
                        -filter    => '*.(xpm|xbm|gif)',
                        ) ;
        $filename = $dialog->Show ;

        &cursor( -1 ) ; 
    }

    if( $filename ) {
        my $loaded = 0 ;
       
        my $dir = dirname( $filename ) ;
        if( $Opt{DIR} ne $dir ) {
            $Opt{DIR} = &abs_path( $dir ) ;
            $Global{WROTE_OPTS} = 0 ;
        }

        if( $filename =~ /.xpm$/o ) {
            %Image = () ;

            $loaded = &xpm::load( $filename ) ;
        }
        elsif( $filename =~ /.xbm$/o or $filename =~ /.gif$/o ) {
            %Image = () ;

            $loaded = &gif::load( $filename ) ;
        }
        else {
            message( 'Warning', 'Open', 'Can only open xpm, xbm and gif files' ) ;
        }

        $Global{WROTE_IMAGE} = 1 ;

        if( $loaded ) {
            $filename = &abs_path( $filename ) ;
            $Global{FILENAME} = $filename ;
            $Win->title( $filename . '  Pixmaped' ) ;
            &file::remember_name( $filename ) ;
            @Undo = () ;
        }
    }
}


sub save {
    package main ;

    if( $Global{FILENAME} =~ /^$Const{FILENAME}/o ) {
        &file::save_as ;
    }
    else {
        $Global{FILENAME} = &abs_path( $Global{FILENAME} ) ;
        if( $Global{FILENAME} =~ /\.xpm$/o ) {
            $Global{WROTE_IMAGE} = 1 if &xpm::save( $Global{FILENAME} ) ; 
        }
        elsif( $Global{FILENAME} =~ /\.gif$/o ) {
            $Global{WROTE_IMAGE} = 1 if &gif::save( $Global{FILENAME} ) ; 
        }
        elsif( $Global{FILENAME} =~/\.ps$/o ) {
            $Grid{CANVAS}->postscript( -file => $Global{FILENAME} ) ;
        }
        &file::remember_name( $Global{FILENAME} ) ;
        @Undo = () unless $Opt{UNDO_AFTER_SAVE} ;
   }
}


sub remember_name {
    package main ;

    my $filename = shift ;

    return if $filename =~ /\.ps$/o ; # We can't load these.

    my $remembered = 0 ;
    for( my $i = 1 ; $i <= $Const{LAST_FILE_MAX} ; $i++ ) {
        $remembered = 1, last if $Opt{"LAST_FILE_$i"} eq $filename ;
    }
    if( not $remembered ) {
        $MenuFile->entryconfigure(
            "$Opt{LAST_FILE} " . $Opt{"LAST_FILE_$Opt{LAST_FILE}"},
            -label => "$Opt{LAST_FILE} " . $filename ) ;
        $Opt{"LAST_FILE_$Opt{LAST_FILE}"} = $filename ;
        $Opt{LAST_FILE}++ ;
        $Opt{LAST_FILE} = 1 if $Opt{LAST_FILE} > $Const{LAST_FILE_MAX} ;
    }
}


sub save_as {
    package main ;

    &cursor( 1, 'clock' ) ;
    $Opt{DIR}    = &abs_path( $Opt{DIR} ) ;

    my $dialog   = $Win->FileSelect( 
                    -directory => $Opt{DIR},
                    -filter    => '*.(xpm|gif|ps)',
                    ) ;
    my $filename = $dialog->Show ;
   
    if( $filename =~ /\.xpm$/o or 
        $filename =~ /\.gif$/o or
        $filename =~ /\.ps$/o # Saves canvas - not image!
        ) {
        # File is saveable.
    }
    else {
        message( 'Warning', 'Save', 'Can only save xpm and gif files' ) ;
        $filename = '' ;
    }
 
    &cursor( -1 ) ;

    if( $filename and -e $filename ) {
        &cursor( 1, 'clock' ) ;

        my $msg = $Win->MesgBox(
                        -title     => "Pixmaped Overwrite File?",
                        -text      => "'$filename' exists - overwrite?",
                        -icon      => 'QUESTION',
                        -buttons   => [ 'Yes', 'No' ],
                        -defbutton => 'No',
                        -canbutton => 'No',
                        ) ;
        my $ans = $msg->Show ;

        &cursor( -1 ) ;
        $filename = '' if $ans eq 'No' ;
    } 

   if( $filename ) {
        $Global{FILENAME} = &abs_path( $filename ) ;
        $Win->title( $Global{FILENAME} . '  Pixmaped' ) ;
        &file::save ;
    }
}


sub prompt_save {
    package main ;

    my $msg = $Win->MesgBox(
        -title     => 'Save Image?',
        -text      => "Save '$Global{FILENAME}'?", 
        -icon      => 'QUESTION',
        -buttons   => [ 'Yes', 'No' ],
        -defbutton => 'Yes',
        ) ;
    my $ans = $msg->Show ;

    &file::save if $ans eq 'Yes' ;
}


sub quit {
    package main ;

    &file::prompt_save unless $Global{WROTE_IMAGE} ;
    &write_opts ; # unless $Global{WROTE_OPTS} ;
    
    exit ;
}


1 ;
