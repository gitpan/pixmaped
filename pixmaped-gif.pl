#!/usr/bin/perl -w

# $Id: pixmaped-gif.pl,v 1.10 1999/02/28 17:47:16 root Exp $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package gif ;


sub load {
    package main ;

    my $filename = shift ;
    my $loaded   = 1 ;

    &cursor( 1, 'watch' ) ;
    &grid::status( "Loading '$filename'..." ) ;

    eval {
        &file::new_image ;
        &gif::gd2xpm( $filename ) ;
    } ;
    if( $@ ) {
        $loaded = 0 ;
        my $err = substr( $@, 0, rindex( $@, ' at' ) ) ;
        message( 'Warning', 'Load',"Failed to load '$filename':\n$err" ) ;
    }

    &xpm::read_image( $filename ) if $loaded ; 

    &cursor( -1 ) ;
    &grid::status( '' ) ;

    $loaded ;
}


sub save {
    package main ;

    my $filename = shift ;
    my $saved    = 1 ;

    &cursor( 1, 'watch' ) ;
    &grid::status( "Saving '$filename'..." ) ;

    eval {
        &gif::xpm2gd( $filename ) ;
    } ;
    if( $@ ) {
        $saved  = 0 ;
        my $err = substr( $@, 0, rindex( $@, ' at' ) ) ;
        message( 'Warning', 'Save',"Failed to save '$filename':\n$err" ) ;
    }

    &xpm::read_image( $filename ) if $saved ; 

    &cursor( -1 ) ;
    &grid::status( '' ) ;

    $saved ;
}


sub gd2xpm {
    package main ;

    my $filename = shift ;

    my $img ;

    # Read the image from file.
    open( IMG, $filename ) or die "Failed to load '$filename':$!" ;
    if( $filename =~ /\.gif$/o ) {
        $img = newFromGif GD::Image( *IMG ) or die "Failed to read '$filename'" ;
    }
    elsif( $filename =~ /\.xbm$/o ) {
        $img = newFromXbm GD::Image( *IMG ) or die "Failed to read '$filename'" ;
    }
    else {
        die "Unrecognised file type" ;
    }
    close IMG ;

    ( $Image{WIDTH}, $Image{HEIGHT} ) = $img->getBounds ;
    $Opt{GRID_WIDTH}  = $Image{WIDTH}  ;
    $Opt{GRID_HEIGHT} = $Image{HEIGHT} ;

    &grid::create ;

    %{$Image{PALETTE}} = () ;
    $Image{COLOURS}    = 0 ;
    my %seen           = () ;
    my $key            = '!' ; 
    my( $red, $green, $blue ) ;
    my $colour ;
    my $transparent ;

    # Set up transparent if its in the image.
    my $colour_index = $img->transparent ; 
    if( $colour_index != -1 ) {
        ( $red, $green, $blue ) = $img->rgb( $colour_index ) ;
        $transparent = sprintf "#%02X%02X%02X", $red, $green, $blue ;
        $Image{PALETTE}{' '} = 'None' ;
    }

    # Read the image data, creating the colour table and drawing at the same
    # time.
    for( my $y = 0 ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
        for( my $x = 0 ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
            $colour_index = $img->getPixel( $x, $y ) ; 
            ( $red, $green, $blue ) = $img->rgb( $colour_index ) ;
            $colour = sprintf "#%02X%02X%02X", $red, $green, $blue ;
            if( defined $transparent and $transparent eq $colour ) { 
                ; # Do nothing, transparent is the default background.
            }
            else {
                &grid::set_colour( $x, $y, $colour ) ;
                if( not $seen{$colour}++ ) {
                    $Image{COLOURS}++ ;
                    die "Ran out of colour space" 
                    if $Image{COLOURS} > $Const{COLOURS_MAX} ;
                    $Image{PALETTE}{$key} = $colour ;
                    while( 1 ) {
                        $key = chr( ord( $key ) + 1 ) ;
                        last unless $key =~ /['"\\]/o ;
                    }
                }
            }
        }
        &grid::coords( $y ) if $Opt{SHOW_PROGRESS} ;
    }
}


sub xpm2gd {
    package main ;

    my $filename = shift ;

    my $img = new GD::Image( $Opt{GRID_WIDTH}, $Opt{GRID_HEIGHT} ) or 
    die "Failed to create image in memory" ;

    my %colour = () ;
    my %seen   = () ;

    $colour{'None'} = $img->colorAllocate( 0, 0, 1 ) ;
    $seen{'None'}   = 1 ;

    $img->transparent( $colour{'None'} ) ;

    for( my $x = 0 ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
        for( my $y = 0 ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
            my $colour = $Grid{SQUARES}[$x][$y]{COLOUR} ;
            if( not $seen{$colour}++ ) { # New colour to allocate.
                my( $red, $green, $blue ) = $Win->rgb( $colour ) ;
                $colour{$colour} = $img->colorAllocate( $red, $green, $blue ) ;
            }
            $img->setPixel( $x, $y, $colour{$colour} ) ;
        }
        &grid::coords( $x ) if $Opt{SHOW_PROGRESS} ;
    } 

    # Write the image from file.
    open( IMG, ">$filename" ) or die "Failed to load '$filename':$!" ;
    binmode IMG ; # For Win users.
    if( $filename =~ /\.gif$/o ) {
        print IMG $img->gif ;
    }
    else {
        die "Unrecognised file type" ;
    }
    close IMG ;
}


1 ;
