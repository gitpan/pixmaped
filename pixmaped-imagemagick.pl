#!/usr/bin/perl -w

# $Id: pixmaped-imagemagick.pl,v 1.8 1999/08/08 15:47:20 root Exp $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the GPL.

use strict ;

package miff ;


sub load {
    package main ;

    my $filename = shift ;
    my $loaded   = 1 ;

    eval {
        &file::new_image ;
        &miff::miff2xpm( $filename ) ;
    } ;
    if( $@ ) {
        $loaded = 0 ;
        my $err = ":\n" . substr( $@, 0, rindex( $@, ' at' ) ) ;
        $err = '' if $err =~ /Failed to load/o ;
        message( 'Warning', 'Load',"Failed to load `$filename'$err" ) ;
    }

    &xpm::read_image( $filename ) if $loaded ; 

    $loaded ;
}


sub save {
    package main ;

    my $filename = shift ;
    my $saved    = 1 ;

    eval {
        &miff::xpm2miff( $filename ) ;
    } ;
    if( $@ ) {
        $saved  = 0 ;
        my $err = substr( $@, 0, rindex( $@, ' at' ) ) ;
        message( 'Warning', 'Save',"Failed to save `$filename':\n$err" ) ;
    }

    &xpm::read_image( $filename ) if $saved ; 

    $saved ;
}


sub miff2xpm {
    package main ;

    my $filename = shift ;

    my $img = Image::Magick->new ;

    # Read the image from file.
    my $err = $img->Read( $filename ) ;
    die $err if $err ;

    ( $Image{WIDTH}, $Image{HEIGHT} ) = $img->Get( 'width', 'height' ) ;
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
    if( $img->Get( 'matte' ) eq 'True' ) {
        my $matte = $img->Get( 'mattecolor' ) ;
		( $red, $green, $blue ) = $Win->rgb( $matte ) ;
		$transparent = sprintf "#%02X%02X%02X", $red, $green, $blue ;
		$Image{PALETTE}{' '} = 'None' ;
    }

    # Read the image data, creating the colour table and drawing at the same
    # time.
    for( my $y = 0 ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
        for( my $x = 0 ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
            my $colour = $img->Get( "pixel[$x,$y]" ) ;
            ( $red, $green, $blue ) = split /,/, $colour ;
            $colour = sprintf "#%02X%02X%02X", $red, $green, $blue ;
            if( defined $transparent and $transparent eq $colour ) { 
                ; # Do nothing, transparent is the default background.
            }
            else {
                &grid::set_colour( $x, $y, $colour ) ;
                if( not $seen{$colour}++ ) {
                    $Image{COLOURS}++ ;
					message( 'Warning', 'Load', "Ran out of colour space" )
                    if $Image{COLOURS} == $Const{COLOURS_MAX} + 1 ;
                    $Image{PALETTE}{$key} = $colour ;
                    while( 1 ) {
                        $key = chr( ord( $key ) + 1 ) ;
                        last unless $key =~ /['"\\]/o ; #'
                    }
                }
            }
        }
        &grid::coords( $y ) if $Opt{SHOW_PROGRESS} ;
    }

    undef $img ; # Recycle memory.
}


sub xpm2miff {
    package main ;

    my $filename = shift ;

    my $img = Image::Magick->new ;
    $img->Set( 'size' => "$Opt{GRID_WIDTH}x$Opt{GRID_HEIGHT}" ) ;
    $img->ReadImage( 'xc:white' ) ;
    $img->Transparent( 'color' => $Const{GRID_BACKGROUND_COLOUR} ) ;

    for( my $x = 0 ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
        for( my $y = 0 ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
            my $colour = $Grid{SQUARES}[$x][$y]{COLOUR} ne 'None' ?
						 $Grid{SQUARES}[$x][$y]{COLOUR} :  
						 $Const{GRID_BACKGROUND_COLOUR} ; 
            $img->Set( "pixel[$x,$y]" => $colour ) ;
        }
        &grid::coords( $x ) if $Opt{SHOW_PROGRESS} ;
    } 

    my $err = $img->Write( $filename ) ;
    die $err if $err ;

    undef $img ; # Recycle memory.
}


1 ;
