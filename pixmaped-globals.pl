#!/usr/bin/perl -w

# $Id: pixmaped-globals.pl,v 1.15 1999/02/28 10:26:17 root Exp $

# Copyright (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package main ;


$Global{WROTE_OPTS}         = 0 ;
$Global{WROTE_IMAGE}        = 1 ;
$Global{FILENAME_INDEX}     = 1 ;
$Global{FILENAME}           = '' ;
$Global{FILE_SUFFIX}        = '.xpm' ;

$Global{ACTIVE_BUTTON}      = 'GRAB_COLOUR' ;
$Global{ACTIVE_IMPLEMENT}   = 'PENCIL' ;
$Global{ACTIVE_TOOL}        = 'pencil' ;
$Global{COLOUR}             = 'white' ;
$Global{CURSOR_LOCK}        = 0 ;
$Global{BUFFER}             = 0 ;

1 ;
