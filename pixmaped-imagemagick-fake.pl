#!/usr/bin/perl -w

# $Id: pixmaped-imagemagick-fake.pl,v 1.1 1999/03/06 19:51:40 root Exp $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package imagemagick ;


sub load {
    package main ;

    message( 'Warning', 'Load',"Load not available - no ImageMagick library found" ) ;
}


sub save {
    package main ;

    message( 'Warning', 'Save',"Save not available - no ImageMagick library found" ) ;
}


1 ;
