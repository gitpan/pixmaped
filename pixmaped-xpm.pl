#!/usr/bin/perl -w

# $Id: pixmaped-xpm.pl,v 1.28 1999/03/07 00:13:26 root Exp $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package xpm ;


sub load {
    package main ;

    my $filename = shift ;
    my $loaded   = 1 ;
    my( $width, $height ) ;

    &cursor( 1, 'watch' ) ;
    &grid::status( "Loading '$filename'..." ) ;

    eval {
        open( XPM, $filename ) or die $! ;
        chomp( @{$Image{LINES}} = <XPM> ) ;
        close XPM ;

        # Parse image data.

        my( $NONE, $COLOURS, $PIXELS ) = ( 0, 1, 2 ) ;
        my $State   = $NONE ;
        my $colours = 0 ;
        my $lino    = 0 ;
        my $y       = 0 ;

        local $_ ;
        foreach( @{$Image{LINES}} ) {
            $lino++ ;
            next unless /^"/o ; # Skip non-data lines.

            my $line = substr( $_, 1 ) ;
            $line =~ s/"[,}]?;?$//o ;
            $line =~ s/\r//go ; # For non-Unix.

            if( $State == $NONE ) {
                ( 
                    $Image{WIDTH},
                    $Image{HEIGHT},
                    $Image{COLOURS},
                    $Image{CPP},
                    $Image{HOTX},
                    $Image{HOTY},
                ) = split( ' ', $line ) ;

                message( 'Info', 'Load', 
                    "This image uses $Image{CPP} chars per pixel.\n" .
                    "Will save using 1 char/pixel" )
                if $Image{CPP} > 1 ;

                die "Cannot save more than $Const{COLOURS_MAX} colours.\n" .
                    "This image uses $Image{COLOURS}" 
                if $Image{COLOURS} > $Const{COLOURS_MAX} ;

                message( 'Info', 'Load', 
                    "Image contains a hotspot - these are not yet supported" )
                if defined $Image{HOTX} and defined $Image{HOTY} ;

                $Opt{GRID_WIDTH}  = $Image{WIDTH} ;
                $Opt{GRID_HEIGHT} = $Image{HEIGHT} ;
                &grid::create ;

                $State = $COLOURS ;
            }
            elsif( $State == $COLOURS ) {
                my $chars = substr( $line, 0, $Image{CPP} ) ;
                # BUG: XPM colour handling is much more sophisticated - but if
                # you want sophistication you need the gimp...
                my $line = substr( $line, $Image{CPP} ) ;
                $line =~ /c\s+([^"]+)/o ; 
                # $1 now has either 'c colour' or 'c colour m text s text' etc.
                my $colour = $1 ;
                $colour =~ s/\s+[ms]\s+.*//o ;
                $colour ? $Image{PALETTE}{$chars} = $colour : 
                     die "Cannot read colour on line $lino" ;
                $colours++ ;
                $State = $PIXELS if $colours >= $Image{COLOURS} ;
            }
            elsif( $State == $PIXELS ) {
                last if /^XPMEXT/o ;
                for( my $x = 0 ; $x < $Image{WIDTH} ; $x++ ) {
                    my $pixel = substr( 
                                    $line, 
                                    $x * $Image{CPP}, 
                                    $Image{CPP}
                                    ) ;
                    &grid::set_colour( $x, $y, $Image{PALETTE}{$pixel} ) ;
                }
                $y++ ;
                &grid::coords( $y ) if $Opt{SHOW_PROGRESS} ;
            }
            else {
                die "Became confused on line $lino" ;
            }
            $Grid{CANVAS}->update ;
        }
    } ;
    if( $@ ) {
        $loaded = 0 ;
        my $err = substr( $@, 0, rindex( $@, ' at' ) ) ;
        message( 'Warning', 'Load',"Failed to load '$filename':\n$err" ) ;
    }


    &xpm::read_image( $filename ) if $loaded ; 

    &cursor( -1 ) ;
    &grid::status( '' ) ;

    $loaded ;
}


sub save {
    package main ;

    my $filename = shift ;
    my $saved    = 1 ;

    &cursor( 1, 'watch' ) ;
    &grid::status( "Saving '$filename'..." ) ;

    eval {
        open( XPM, ">$filename" ) or die $! ;

        eval {
            my $xpm = basename( $filename ) ;
            $xpm =~ s/[- .]/_/go ;

            my( $NONE, $SKIP, $DATA ) = ( 0, 1, 2 ) ;
            my $State     = $NONE ;
            my $lino      = 0 ;
            my $last_line = 0 ;

            local $_ ;
            foreach( @{$Image{LINES}} ) {
                $lino++ ;
                # Print comment and non-data lines plus the variable line.
                unless( /^"/o ) {
                    # Change the filename if we've done a save as.
                    $_ = "$1$xpm$3"  
                    if /^(.*static char\s*\*\s*)(\S+)(\[\].*)$/o and $2 ne $xpm ;
                    print XPM "$_\n" ;
                    $last_line = 1 if /}\s*;/o ;
                    next ;          
                }
    
                my $line = substr( $_, 1 ) ;
                $line =~ s/"[,}]?;?$//o ;
                $line =~ s/\r//go ; # For non-Unix.

                if( $State == $NONE ) { # Write values line.
                    # BUG: We only write 1 cpp.
                    $Image{CPP} = 1 ;

                    &xpm::prepare_palette ;

                    # BUG: We cannot take an image that uses 1 cpp and
                    # transform it into one that uses 2 or more cpp.
                    # BUG: We are ignoring hotspots.
                    my $values = "$Image{WIDTH} $Image{HEIGHT} " .
                                 "$Image{COLOURS} $Image{CPP}" ; 
                    $line =~ s/^(\s*\S+\s+\S+\s+\S+\s+\S+)/$values/o ;
                    print XPM qq{"$line",\n} ;

                    # Write out the colour table.
                    my %colours ;
                    my $i = 0 ;
                    foreach my $colour ( keys %{$Image{PALETTE}} ) {
                        next if substr( $colour, 0, 1 ) eq '_' ;
                        # BUG: If the original had monochrome colours or
                        # symbolic names they are lost.
                        print XPM qq{"$colour c $Image{PALETTE}{$colour}",\n} ;    
                        $colours{$Image{PALETTE}{$colour}} = $colour ;
                        $i++ ;
                    }
                    die "Too few colours written"  if $i < $Image{COLOURS} ;
                    die "Too many colours written" if $i > $Image{COLOURS} ;

                    # Write out the image itself.
                    for( my $y = 0 ; $y < $Image{HEIGHT} ; $y++ ) {
                        print XPM qq{"} ;
                        for( my $x = 0 ; $x < $Image{WIDTH} ; $x++ ) {
                            print XPM "$colours{$Grid{SQUARES}[$x][$y]{COLOUR}}" ; 
                        }
                        print XPM qq{",\n} ;
                        &grid::coords( $y ) if $Opt{SHOW_PROGRESS} ;
                    }
                    $State = $SKIP ; 
                }
                elsif( $State == $SKIP ) {
                    # Here we skip colour and pixel lines from the original
                    # data.
                    print XPM "$_\n", $State = $DATA if /^"XPMEXT/o ;
                }
                else { # $State == $DATA
                    print XPM "$_\n" ; # Print data.
                }
            }
            print XPM "};\n" unless $last_line ;
        } ;

        close XPM or die $! ; # Close in all cases.

        die $@ if $@ ; # Pass up an exceptions.
    } ;
    if( $@ ) {
        $saved  = 0 ;
        my $err = substr( $@, 0, rindex( $@, ' at' ) ) ;
        message( 'Warning', 'Save',"Failed to save '$filename':\n$err" ) ;
    }


    &xpm::read_image( $filename ) if $saved ; 

    &cursor( -1 ) ;
    &grid::status( '' ) ;

    $saved ;
}


sub prepare_palette {
    package main ;

    %{$Image{PALETTE}} = () ;
    $Image{COLOURS}    = 0 ;
    my %seen           = () ;
    my $key            = '!' ; 

    for( my $x = 0 ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
        for( my $y = 0 ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
            my $colour = $Grid{SQUARES}[$x][$y]{COLOUR} ;
            if( not $seen{$colour}++ ) {
                $Image{COLOURS}++ ;
                die "Ran out of colour space" 
                if $Image{COLOURS} > $Const{COLOURS_MAX} ;
                if( $colour eq 'None' ) {
                    $Image{PALETTE}{' '} = 'None' ;
                }
                else {
                    $Image{PALETTE}{$key} = $colour ;
                    while( 1 ) {
                        $key = chr( ord( $key ) + 1 ) ;
                        last unless $key =~ /['"\\]/o ;
                    }
                }
            }
        }
    }
}


sub read_image {
    package main ;

    my $filename = shift ;

	$Image{PIXMAP} = undef ;

    if( $filename =~ /\.xpm$/o ) {
        $Image{PIXMAP} = $Win->Pixmap( -file => $filename ) ;
    }
    elsif( $filename =~ /\.gif$/o ) {
        $Image{PIXMAP} = $Win->Photo( -file => $filename ) ;
    }
    elsif( $filename =~ /\.xbm$/o ) {
        $Image{PIXMAP} = $Win->Bitmap( -file => $filename ) ;
    }
 
    $Grid{PIXMAP}->configure(
        -image  => $Image{PIXMAP}, 
        -width  => $Image{WIDTH},
        -height => $Image{HEIGHT},
        )
    if defined $Image{PIXMAP} ;

    $Opt{GRID_WIDTH}  = $Image{WIDTH} ;
    $Opt{GRID_HEIGHT} = $Image{HEIGHT} ;
}


1 ;
