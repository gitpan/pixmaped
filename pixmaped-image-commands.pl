#!/usr/bin/perl -w

# $Id: pixmaped-image-commands.pl,v 1.10 1999/12/13 19:26:06 root Exp root $

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
