#!/usr/bin/perl -w

# $Id: misc.pl,v 1.5 1999/09/05 12:10:46 root Exp root $

# Copyright (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the LGPL. 

use strict ;

use Cwd ;

package main ;


sub abs_path {
    my $path = shift ;

    my $filename = basename( $path ) ;

    $path        = dirname( $path ) ;
    chdir $path ;
    $path = cwd ;

    $path =~ s!/\./!/!go ;

    if( $filename ) {
        $path .= '/' unless substr( $path, -1, 1 ) eq '/' ;
        $path .= $filename ;
    }

    $path ;
}


# Copied from The Perl Cookbook
sub commify {
    my $num = reverse $_[0] ;
    $num =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g ;
    scalar reverse $num ;
}


1 ;
