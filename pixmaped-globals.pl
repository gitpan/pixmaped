#!/usr/bin/perl -w

# $Id: pixmaped-globals.pl,v 1.21 1999/12/13 19:26:06 root Exp root $

# Copyright (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the GPL.

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
$Global{BUFFER}             = 0 ;
$Global{X}                  = 0 ;
$Global{Y}                  = 0 ;

1 ;
