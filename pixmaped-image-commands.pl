#!/usr/bin/perl -w

# $Id: pixmaped-image-commands.pl,v 1.9 1999/08/08 15:47:20 root Exp $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the GPL.

use strict ;

package image ;


sub zoom {
    package main ;

    shift if ref $_[0] ;
    $Opt{GRID_SQUARE_LENGTH} = shift ;

    &grid::redraw ;
}


1 ;
