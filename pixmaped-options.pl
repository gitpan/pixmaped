#!/usr/bin/perl -w

# $Id: pixmaped-options.pl,v 1.23 1999/12/13 19:26:06 root Exp root $

# Copyright (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the GPL.

use strict ;

package options ;

my $OptionsWin ; 

# Local variables to store values. Want them global to the module.
my( $GridWidth,
    $GridHeight, 
    $GridSquareLength, 
    ) ;

sub options {
    package main ;

    &cursor( 'clock' ) ;
    &grid::status( 'Setting preferences...' ) ;

    # Start with existing values.
    $GridWidth        = $Opt{GRID_WIDTH}  ;
    $GridHeight       = $Opt{GRID_HEIGHT} ;
    $GridSquareLength = $Opt{GRID_SQUARE_LENGTH} ;

    # Set up the options window. 
    $OptionsWin = $Win->Toplevel() ;
    $OptionsWin->title( 'Pixmaped Preferences' ) ;
    $OptionsWin->protocol( "WM_DELETE_WINDOW", [ \&options::close, 0 ] ) ;

    &options::key_bindings ;

    # Scales.
    my $scale ; 

    $scale = &options::create_scale(
        $Const{GRID_WIDTH_MIN}, $Const{GRID_WIDTH_MAX}, 
        10, "Default image width (pixels)", 0 ) ;
    $scale->configure( -variable => \$GridWidth ) ;
    $scale->focus ;

    $scale = &options::create_scale(
        $Const{GRID_HEIGHT_MIN}, $Const{GRID_HEIGHT_MAX}, 
        10, "Default image height (pixels)", 2 ) ;
    $scale->configure( -variable => \$GridHeight ) ;
 
    $scale = &options::create_scale(
        $Const{GRID_SQUARE_LENGTH_MIN}, $Const{GRID_SQUARE_LENGTH_MAX},
        2, "Zoom x", 4 ) ;
    $scale->configure( -variable => \$GridSquareLength ) ;

    my $Frame = $OptionsWin->Frame()->grid( 
                    -row        => 9, 
                    -column     => 0,
                    -columnspan => 3,
                    ) ;

    # Save button.
    $Frame->Button(
        -text      => 'Save',
        -underline => 0,
        -width     => $Const{BUTTON_WIDTH},
        -command   => [ \&options::close, 1 ],
        )->pack( -side => 'left' ) ;

    # Cancel button.
    $Frame->Button(
        -text      => 'Cancel',
        -underline => 0,
        -width     => $Const{BUTTON_WIDTH},
        -command   => [ \&options::close, 0 ],
        )->pack( -side => 'left' ) ;

    # Defaults button.
    $Frame->Button(
        -text      => 'Defaults',
        -underline => 0,
        -width     => $Const{BUTTON_WIDTH},
        -command   => \&options::defaults,
        )->pack( -side => 'left' ) ;
}

sub create_scale {
    my( $min, $max, $interval, $title, $row ) = @_ ;

    my $scale = $OptionsWin->Scale( 
        -orient       => 'horizontal',
        -from         => $min,
        -to           => $max,
        -tickinterval => $interval,
        -label        => $title,
        '-length'     => 300,
        )->grid( -row => $row, -column => 0, -rowspan => 2, -columnspan => 3 ) ;

    $scale ;
}

sub key_bindings {

    # Cancel keygrid bindings.
    $OptionsWin->bind( '<Alt-c>',     [ \&close, 0 ] ) ;
    $OptionsWin->bind( '<Control-c>', [ \&close, 0 ] ) ;
    $OptionsWin->bind( '<Escape>',    [ \&close, 0 ] ) ;

    # Save keygrid bindings.
    $OptionsWin->bind( '<Alt-s>',     [ \&close, 1 ] ) ;
    $OptionsWin->bind( '<Control-s>', [ \&close, 1 ] ) ;
    $OptionsWin->bind( '<Return>',    [ \&close, 1 ] ) ;
    
    # Defaults keygrid bindings.
    $OptionsWin->bind( '<Alt-d>',     \&defaults ) ;
    $OptionsWin->bind( '<Control-d>', \&defaults ) ;
}

sub close {
    package main ;

    shift if ref $_[0] ; # Some callers include an object ref.
    my $save = shift ;

    if( $save ) {
        my $must_save = 0 ;
       
        if( ( $GridWidth  != $Opt{GRID_WIDTH} ) or
            ( $GridHeight != $Opt{GRID_HEIGHT} ) ) {
            $must_save = 1 ;
        }

        $Image{WIDTH}  = $Opt{GRID_WIDTH}  = $GridWidth ;
        $Image{HEIGHT} = $Opt{GRID_HEIGHT} = $GridHeight ;

        if( $must_save ) {
            &file::prompt_save unless $Global{WROTE_IMAGE} ;
            if( $Global{FILENAME} !~ /^$Const{FILENAME}/o ) {
                &file::open( $Global{FILENAME} ) ;
            }
            else {
                &grid::create ;
            }
        }

        if( not $must_save and 
            $GridSquareLength != $Opt{GRID_SQUARE_LENGTH} ) {
            $Opt{GRID_SQUARE_LENGTH} = $GridSquareLength ;
            &grid::redraw ;
        }

        &write_opts ;
    }

    &cursor() ;
    &grid::status( '' ) ;
    $OptionsWin->destroy ;
}

sub defaults {
    package main ;

    $GridWidth        = $Const{GRID_WIDTH_DEF} ;
    $GridHeight       = $Const{GRID_HEIGHT_DEF} ;
    $GridSquareLength = $Const{GRID_SQUARE_LENGTH_DEF} ;
}

1 ;
