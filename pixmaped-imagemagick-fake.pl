#!/usr/bin/perl -w

# $Id: pixmaped-imagemagick-fake.pl,v 1.4 1999/12/13 19:26:06 root Exp root $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the GPL.

use strict ;

package miff ;

sub load {
    package main ;

    message( 'Warning', 'Load',"Load not available - no ImageMagick library found" ) ;
}

sub save {
    package main ;

    message( 'Warning', 'Save',"Save not available - no ImageMagick library found" ) ;
}

1 ;
