#!/usr/bin/perl -w

# $Id: pixmaped-grid.pl,v 1.15 1999/02/28 13:14:38 root Exp $

# Copyright (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package main ;


my $StatusFrame = $Win->Frame()->pack( 
                -side   => 'bottom', 
                -expand => 1, 
                -fill   => 'both',
                -padx   => 5,
                -pady   => 5,
                ) ;

$Image{PIXMAP} = $Win->Pixmap( -file => "$RealBin/pixmaped-new.xpm" ) ;

$Grid{PIXMAP} = $StatusFrame->Label( 
                        -image  => $Image{PIXMAP}, 
                        -width  => $Opt{GRID_WIDTH},
                        -height => $Opt{GRID_HEIGHT},
                        -relief => 'ridge',
                        )->pack( -side => 'left' ) ;

$Grid{COORDS} = $StatusFrame->Label( 
                    -text   => '0,0',
                    -relief => 'ridge',
                    -anchor => 'w',
                    )->pack( 
                        -side => 'left', 
                        -pady => 3,
                        ) ;

$Grid{FLAGS} = $StatusFrame->Label( 
                    -text   => '',
                    -relief => 'ridge',
                    -anchor => 'w',
                    )->pack( 
                        -side => 'left', 
                        -pady => 3,
                        ) ;

$Grid{STATUS} = $StatusFrame->Label( 
                    -text   => '',
                    -relief => 'ridge',
                    -anchor => 'w',
                    )->pack( 
                        -side   => 'left', 
                        -fill   => 'x', 
                        -expand => 1,
                        -pady   => 3,
                        ) ;


my $CanvasFrame = $Win->Frame()->pack(
                -side   => 'top',
                -expand => 1,
                -fill   => 'both',
                ) ;


$Grid{XSCROLL} = $CanvasFrame->Scrollbar( -orient => 'horizontal' ) ;
$Grid{YSCROLL} = $CanvasFrame->Scrollbar() ;

$Grid{CANVAS} = $CanvasFrame->Canvas(
                    -width       => $Const{GRID_WIDTH_DEF}, 
                    -height      => $Const{GRID_HEIGHT_DEF},
                    -borderwidth => 1,
                    -xscrollcommand => [ 'set', $Grid{XSCROLL} ],
                    -yscrollcommand => [ 'set', $Grid{YSCROLL} ],
                    -scrollregion   => [ 0, 0, 
                                         $Const{GRID_WIDTH_DEF},
                                         $Const{GRID_HEIGHT_DEF} ],
                    ) ;

$Grid{XSCROLL}->configure( -command => [ 'xview', $Grid{CANVAS} ] ) ;
$Grid{YSCROLL}->configure( -command => [ 'yview', $Grid{CANVAS} ] ) ;

$Grid{XSCROLL}->pack( -side => 'bottom', -fill => 'x' ) ;
$Grid{YSCROLL}->pack( -side => 'left',   -fill => 'y' ) ;
$Grid{CANVAS}->pack(  -side => 'bottom', -fill => 'both', -expand => 1 ) ; 

$Grid{CANVAS}->Tk::bind( '<1>',               \&grid::click1 ) ;
$Grid{CANVAS}->Tk::bind( '<ButtonRelease-1>', \&grid::release1 ) ;
$Grid{CANVAS}->Tk::bind( '<B1-Motion>',       \&grid::motion1 ) ;
$Grid{CANVAS}->Tk::bind( '<2>',               \&grid::click2 ) ;
$Grid{CANVAS}->Tk::bind( '<3>',               \&grid::click3 ) ;
$Grid{CANVAS}->Tk::bind( '<Leave>',           \&grid::leave ) ;
 

1 ;
