#!/usr/bin/perl -w

# $Id: pixmaped-gif-fake.pl,v 1.1 1999/02/20 18:29:16 root Exp $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package gif ;


sub load {
    package main ;

    message( 'Warning', 'Load',"Load gif/xbm not available - no GD library found" ) ;
}


sub save {
    package main ;

    message( 'Warning', 'Save',"Save gif not available - no GD library found" ) ;
}


1 ;
