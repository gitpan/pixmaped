#!/usr/bin/perl -w

# $Id: pixmaped-image-commands.pl,v 1.8 1999/03/20 13:32:36 root Exp $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package image ;


sub zoom {
    package main ;

    shift if ref $_[0] ;
    $Opt{GRID_SQUARE_LENGTH} = shift ;

    &grid::redraw ;
}


1 ;
