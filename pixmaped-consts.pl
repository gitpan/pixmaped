#!/usr/bin/perl -w

# $Id: pixmaped-consts.pl,v 1.28 1999/02/27 19:43:40 root Exp $

# Copyright (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package main ;


if( $^O =~ /win32/oi ) {
    $Const{OPTS_FILE} = 'PIXMAPED.INI' ;
}
else {
    $Const{OPTS_FILE} = ( $ENV{HOME} or $ENV{LOGDIR} or (getpwuid( $> ))[7])
                        . '/.pixmaped-opts' ;
}

$Const{BUTTON_WIDTH}           =  8 ;

$Const{GRID_WIDTH_DEF}         = 32 ; 
$Const{GRID_WIDTH_MIN}         =  5 ; 
$Const{GRID_WIDTH_MAX}         = 96 ; 

$Const{GRID_HEIGHT_DEF}        = 32 ; 
$Const{GRID_HEIGHT_MIN}        =  5 ; 
$Const{GRID_HEIGHT_MAX}        = 96 ; 

$Const{GRID_SQUARE_LENGTH_DEF} = 12 ; 
$Const{GRID_SQUARE_LENGTH_MIN} =  2 ; 
$Const{GRID_SQUARE_LENGTH_MAX} = 20 ; 

$Const{GRID_BACKGROUND_COLOUR} = '#DADADA' ;
$Const{GRID_OUTLINE_COLOUR}    = '#CBCBCB' ;

$Const{COLOURS_MAX}            = 94 ;

$Const{FILENAME}               = 'Untitled-' ;
$Const{DIR}                    = '.' ;
$Const{LAST_FILE_MAX}          =  9 ;


my $s = "$RealBin/pixmaped-" ;
$Const{PALETTE_IMAGE}          = $Win->Pixmap( -file => "${s}palette.xpm" ) ;
$Const{TRANSPARENT_IMAGE}      = $Win->Pixmap( -file => "${s}transparent.xpm" ) ;
$Const{PENCIL_IMAGE}           = $Win->Pixmap( -file => "${s}pencil.xpm" ) ;
$Const{FLIP_HORIZONTAL_IMAGE}  = $Win->Pixmap( -file => "${s}flip-horizontal.xpm" ) ;
$Const{FLIP_VERTICAL_IMAGE}    = $Win->Pixmap( -file => "${s}flip-vertical.xpm" ) ;
$Const{BRUSH_IMAGE}            = $Win->Pixmap( -file => "${s}brush.xpm" ) ;
$Const{ROTATE_IMAGE}           = $Win->Pixmap( -file => "${s}rotate.xpm" ) ;
$Const{TEXT_IMAGE}             = $Win->Pixmap( -file => "${s}text.xpm" ) ;
$Const{LINE_IMAGE}             = $Win->Pixmap( -file => "${s}line.xpm" ) ;
$Const{OVAL_IMAGE}             = $Win->Pixmap( -file => "${s}oval.xpm" ) ;
$Const{OVAL_FILLED_IMAGE}      = $Win->Pixmap( -file => "${s}filled-oval.xpm" ) ;
$Const{RECTANGLE_IMAGE}        = $Win->Pixmap( -file => "${s}rectangle.xpm" ) ;
$Const{RECTANGLE_FILLED_IMAGE} = $Win->Pixmap( -file => "${s}filled-rectangle.xpm" ) ;
$Const{FILL_IMAGE}             = $Win->Pixmap( -file => "${s}fill.xpm" ) ;

foreach my $i ( 'A'..'L' ) {
    $Const{"RESIZE_${i}_IMAGE"} = $Win->Pixmap( -file => "${s}resize-${i}.xpm" ) ;
}


1 ;
