#!/usr/bin/perl -w

# $Id: pixmaped-file-commands.pl,v 1.54 1999/09/04 13:25:44 root Exp $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the GPL.

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

    $Win->title( 'Pixmaped - ' . $Global{FILENAME} ) ;
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
        &cursor( 'clock' ) ;
        $Opt{DIR}  = &abs_path( $Opt{DIR} ) ;
        my $dialog = $Win->FileSelect( -directory => $Opt{DIR} ) ;
        $filename = $dialog->Show ;
        &cursor() ; 
    }

    if( $filename ) {
        my $loaded = 0 ;
       
        my $dir = dirname( $filename ) ;
        if( $Opt{DIR} ne $dir ) {
            $Opt{DIR} = &abs_path( $dir ) ;
            $Global{WROTE_OPTS} = 0 ;
        }

		&cursor( 'watch' ) ;
		&grid::status( "Loading `$filename'..." ) ;
        my $time = time ; # DEBUG

        if( $filename =~ /.xpm$/oi ) {
            %Image = () ;

            $loaded = &xpm::load( $filename ) ;
        }
        elsif( $Modules{GD} and 
               ( $filename =~ /.xbm$/oi or $filename =~ /.gif$/oi ) ) {
            %Image = () ;

            $loaded = &gif::load( $filename ) ;
        }
        elsif( $Modules{MIFF} ) {
			%Image = () ;

			$loaded = &miff::load( $filename ) ;
		}
		else {
			message( 'Warning', 'Open', 'Cannot open this file format' ) 
        }

        $Global{WROTE_IMAGE} = 1 ;

        if( $loaded ) {
            $filename = &abs_path( $filename ) ;
            $Global{FILENAME} = $filename ;
            $Win->title( 'Pixmaped - ' . $filename ) ;
            &file::remember_name( 
                $filename, $MenuFile, 'FILE', $Const{LAST_FILE_MAX} ) ;
            @Undo = () ;
        }
       
        if( $DEBUG ) {
            $time = time - $time ; 
            my( $s, $m, $h ) = (gmtime( $time ))[0..2] ; 
            $time = sprintf " %02d:%02d:%02d", $h, $m, $s ; 
        }
        else {
            $time = '' ;
        }
        $time = "Loaded $Global{FILENAME} ($Image{WIDTH}x$Image{HEIGHT})$time" ; 
		&cursor() ;
		&grid::status( '' ) ;
		&grid::status( $time ) if $loaded ;
    }
}


sub save {
    package main ;

    if( $Global{FILENAME} =~ /^$Const{FILENAME}/o ) {
        &file::save_as ;
    }
    else {
        $Global{FILENAME} = &abs_path( $Global{FILENAME} ) ;

		&cursor( 'watch' ) ;
		&grid::status( "Saving `$Global{FILENAME}'..." ) ;

        if( $Global{FILENAME} =~ /\.xpm$/oi ) {
            $Global{WROTE_IMAGE} = 1 if &xpm::save( $Global{FILENAME} ) ; 
        }
        elsif( $Global{FILENAME} =~/\.ps$/oi ) {
            &file::save_as_postscript ;
        }
        elsif( $Modules{GD} and $Global{FILENAME} =~ /\.gif$/oi ) {
            $Global{WROTE_IMAGE} = 1 if &gif::save( $Global{FILENAME} ) ; 
        }
        elsif( $Modules{MIFF} ) {
            $Global{WROTE_IMAGE} = 1 if &miff::save( $Global{FILENAME} ) ; 
        }
        else {
			message( 'Warning', 'Save', 'Cannot save this file format' ) ;
		}
        if( $Global{WROTE_IMAGE} ) {
			&file::remember_name( 
			    $Global{FILENAME}, $MenuFile, 'FILE', $Const{LAST_FILE_MAX} ) ;
			@Undo = () unless $Opt{UNDO_AFTER_SAVE} ;
		}

		&cursor() ;
		&grid::status( '' ) ;
		&grid::status( "Wrote $Global{FILENAME}" ) if $Global{WROTE_IMAGE} ;
   }
}


sub save_as_postscript {
    package main ;

	my $ans = 'Actual' ;

	if( $Opt{GRID_SQUARE_LENGTH} > 1 ) { 
		&cursor( 'clock' ) ;
		my $msg = $Win->MesgBox(
					-title     => "Pixmaped save as postscript",
					-text      => "Save actual size or magnified as shown?",
					-icon      => 'QUESTION',
					-buttons   => [ 'Actual', 'Magnified' ],
					-defbutton => 'Actual',
					) ;
		$ans = $msg->Show ;
		&cursor() ;
	}

	my $gridsize = $Opt{GRID_SQUARE_LENGTH} ;

	if( $ans eq 'Actual' ) {
		$Opt{GRID_SQUARE_LENGTH} = 1 ;
		&grid::redraw ;
	}
	
	$Grid{CANVAS}->postscript( -file => $Global{FILENAME} ) ;
	
	if( $ans eq 'Actual' ) {
		$Opt{GRID_SQUARE_LENGTH} = $gridsize ;
		&grid::redraw ;
    }
}


sub remember_name {
    package main ;

    my( $filename, $Widget, $type, $max ) = @_ ;

    $type = 'LAST_' . $type ;

    my $remembered = 0 ;
    for( my $i = 1 ; $i <= $max ; $i++ ) {
        $remembered = 1, last if $Opt{$type . "_$i"} eq $filename ;
    }
    if( not $remembered ) {
        $Widget->entryconfigure(
            $Opt{$type} . " " . $Opt{$type . "_" . $Opt{$type}},
            -label => $Opt{$type} . " " . $filename ) ;
        $Opt{$type . "_" . $Opt{$type}} = $filename ;
        $Opt{$type}++ ;
        $Opt{$type} = 1 if $Opt{$type} > $max ;
    }
}


sub save_as {
   package main ;

    &cursor( 'clock' ) ;
    $Opt{DIR}    = &abs_path( $Opt{DIR} ) ;
    my $dialog   = $Win->FileSelect( -directory => $Opt{DIR} ) ;
    my $filename = $dialog->Show ;
    &cursor() ;

    if( $filename and -e $filename ) {
        &cursor( 'clock' ) ;

        my $msg = $Win->MesgBox(
                        -title     => "Pixmaped Overwrite File?",
                        -text      => "`$filename' exists - overwrite?",
                        -icon      => 'QUESTION',
                        -buttons   => [ 'Yes', 'No' ],
                        -defbutton => 'No',
                        -canbutton => 'No',
                        ) ;
        my $ans = $msg->Show ;

        &cursor() ;
        $filename = '' if $ans eq 'No' ;
    } 

   if( $filename ) {
        $Global{FILENAME} = &abs_path( $filename ) ;
        $Win->title( 'Pixmaped - ' . $Global{FILENAME} ) ;
		&file::save ;
    }
}


sub prompt_save {
    package main ;

    my $msg = $Win->MesgBox(
        -title     => 'Pixmaped Save Image?',
        -text      => "Save `$Global{FILENAME}'?", 
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
    
    $Win->destroy ;
}


1 ;
