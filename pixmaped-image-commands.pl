#!/usr/bin/perl -w

# $Id: pixmaped-image-commands.pl,v 1.7 1999/02/28 17:28:42 root Exp $

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


sub text {
    package main ;

    my( $x, $y, $text ) = @_ ;

    print STDERR "Write text not implemented yet. ($x,$y)=$text\n" ;
}


1 ;
