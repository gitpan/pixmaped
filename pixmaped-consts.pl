#!/usr/bin/perl -w

# $Id: pixmaped-consts.pl,v 1.35 1999/04/21 20:23:46 root Exp $

# Copyright (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package main ;


if( $^O =~ /win32/oi ) {
    $Const{OPTS_FILE} = 'PIXMAPED.INI' ;
}
else {
    my $home = ( $ENV{HOME} or $ENV{LOGDIR} or (getpwuid( $> ))[7]) ;
    $Const{OPTS_FILE} = $home . '/.pixmaped-opts' ;
    my $xdefaults     = $home . '/.Xdefaults' ;
#    $Win->optionReadfile( $xdefaults ) ; # Does not work: don't know why.
}

$Const{BUTTON_WIDTH}           =  8 ;

$Const{GRID_WIDTH_DEF}         = 32 ; 
$Const{GRID_WIDTH_MIN}         =  5 ; 
$Const{GRID_WIDTH_MAX}         = 96 ; 

$Const{GRID_HEIGHT_DEF}        = 32 ; 
$Const{GRID_HEIGHT_MIN}        =  5 ; 
$Const{GRID_HEIGHT_MAX}        = 96 ; 

$Const{GRID_SQUARE_LENGTH_DEF} = 12 ; 
$Const{GRID_SQUARE_LENGTH_MIN} =  1 ; 
$Const{GRID_SQUARE_LENGTH_MAX} = 20 ; 

$Const{GRID_BACKGROUND_COLOUR} = '#DADADA' ;
$Const{GRID_OUTLINE_COLOUR}    = '#CBCBCB' ;

$Const{COLOURS_MAX}            = 94 ;

$Const{FILENAME}               = 'Untitled-' ;
$Const{DIR}                    = '.' ;
$Const{LAST_FILE_MAX}          =  9 ;

$Const{HELP_FILE}              = "$RealBin/" . "pixmaped-help.pod" ; 

my $p = "$RealBin/pixmaped-" ;
$Const{PALETTE_IMAGE}          = $Win->Pixmap( -file => "${p}palette.xpm" ) ;
$Const{TRANSPARENT_IMAGE}      = $Win->Pixmap( -file => "${p}transparent.xpm" ) ;
$Const{PENCIL_IMAGE}           = $Win->Pixmap( -file => "${p}pencil.xpm" ) ;
$Const{FLIP_HORIZONTAL_IMAGE}  = $Win->Pixmap( -file => "${p}flip-horizontal.xpm" ) ;
$Const{FLIP_VERTICAL_IMAGE}    = $Win->Pixmap( -file => "${p}flip-vertical.xpm" ) ;
$Const{BRUSH_IMAGE}            = $Win->Pixmap( -file => "${p}brush.xpm" ) ;
$Const{ROTATE_IMAGE}           = $Win->Pixmap( -file => "${p}rotate.xpm" ) ;
$Const{TEXT_IMAGE}             = $Win->Pixmap( -file => "${p}text.xpm" ) ;
$Const{LINE_IMAGE}             = $Win->Pixmap( -file => "${p}line.xpm" ) ;
$Const{OVAL_IMAGE}             = $Win->Pixmap( -file => "${p}oval.xpm" ) ;
$Const{RECTANGLE_IMAGE}        = $Win->Pixmap( -file => "${p}rectangle.xpm" ) ;
$Const{RECTANGLE_FILLED_IMAGE} = $Win->Pixmap( -file => "${p}filled-rectangle.xpm" ) ;
$Const{FILL_IMAGE}             = $Win->Pixmap( -file => "${p}fill.xpm" ) ;
$Const{SWAP_IMAGE}             = $Win->Pixmap( -file => "${p}swapcolour.xpm" ) ;

foreach my $i ( 'A'..'L' ) {
    $Const{"RESIZE_${i}_IMAGE"} = $Win->Pixmap( -file => "${p}resize-${i}.xpm" ) ;
}


1 ;
