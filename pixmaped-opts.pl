#!/usr/bin/perl -w

# $Id: pixmaped-opts.pl,v 1.21 1999/03/21 08:36:09 root Exp $

# Copyright (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package main ;


$Opt{INSERT_TRANSPARENT}     = 0 ;

$Opt{GRID_WIDTH}             = $Const{GRID_WIDTH_DEF} ;
$Opt{GRID_HEIGHT}            = $Const{GRID_HEIGHT_DEF} ;
$Opt{GRID_SQUARE_LENGTH}     = $Const{GRID_SQUARE_LENGTH_DEF} ;
$Opt{SHOW_OUTLINE}           = 1 ; 

$Opt{GRID_BACKGROUND_COLOUR} = $Const{GRID_BACKGROUND_COLOUR} ;
$Opt{GRID_OUTLINE_COLOUR}    = $Const{GRID_OUTLINE_COLOUR} ;

$Opt{DIR}                    = $Const{DIR} ;

$Opt{PALETTE_0}              = 'white' ;
$Opt{PALETTE_1}              = 'black' ;
$Opt{PALETTE_2}              = 'red' ;
$Opt{PALETTE_3}              = 'green' ;
$Opt{PALETTE_4}              = 'blue' ;
$Opt{PALETTE_5}              = 'yellow' ;
$Opt{PALETTE_6}              = 'cyan' ;
$Opt{PALETTE_7}              = 'magenta' ;

$Opt{GRAB_COLOUR}            = 'white' ;

$Opt{LAST_FILE}              = 1 ;
$Opt{LAST_FILE_1}            = '(none)' ;
$Opt{LAST_FILE_2}            = '(none)' ;
$Opt{LAST_FILE_3}            = '(none)' ;
$Opt{LAST_FILE_4}            = '(none)' ;
$Opt{LAST_FILE_5}            = '(none)' ;
$Opt{LAST_FILE_6}            = '(none)' ;
$Opt{LAST_FILE_7}            = '(none)' ;
$Opt{LAST_FILE_8}            = '(none)' ;
$Opt{LAST_FILE_9}            = '(none)' ;

$Opt{SHOW_PROGRESS}          = 0 ;

$Opt{BRUSH_SIZE}             =  2 ; # 2 or 3 are valid.
$Opt{ROTATION}               = 90 ; # 90, 180 and 270 are valid.
$Opt{UNDO_AFTER_SAVE}        =  1 ;


sub opts_check {

    $Opt{GRID_WIDTH} = $Const{GRID_WIDTH_DEF} 
    if $Opt{GRID_WIDTH} < $Const{GRID_WIDTH_MIN} or 
       $Opt{GRID_WIDTH} > $Const{GRID_WIDTH_MAX} ; 

    $Opt{GRID_HEIGHT} = $Const{GRID_HEIGHT_DEF} 
    if $Opt{GRID_HEIGHT} < $Const{GRID_HEIGHT_MIN} or 
       $Opt{GRID_HEIGHT} > $Const{GRID_HEIGHT_MAX} ; 

    $Opt{GRID_SQUARE_LENGTH} = $Const{GRID_SQUARE_LENGTH_DEF} 
    if $Opt{GRID_SQUARE_LENGTH} < $Const{GRID_SQUARE_LENGTH_MIN} or 
       $Opt{GRID_SQUARE_LENGTH} > $Const{GRID_SQUARE_LENGTH_MAX} ;

    $Opt{DIR} = '.' unless -d $Opt{DIR} ;

    for( my $i = 1 ; $i <= $Const{LAST_FILE_MAX} ; $i++ ) {
        $Opt{LAST_FILE} = $i, last unless $Opt{"LAST_FILE_$i"} ;
    }

    $Opt{BRUSH_SIZE} =  2 if $Opt{BRUSH_SIZE} != 3 ;
    $Opt{ROTATION}   = 90 if $Opt{ROTATION} > 270 or $Opt{ROTATION} < 90 or
                             $Opt{ROTATION} % 90 != 0 ;
}


1 ;
