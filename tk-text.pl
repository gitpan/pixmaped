#!/usr/bin/perl -w

# $Id: tk-text.pl,v 1.1 1999/03/24 21:11:48 root Exp root $

# Copyright (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package tk::text ;


my $TextBox ;


sub render_pod {
    # render_pod takes two arguments, firstly the textbox to write to and
    # secondly any number of PARAGRAPHS, i.e. when reading text you must set
    # local $/ = '' ;

    $TextBox = shift ;

    &set_text_tags ;

    # Read and render the text.
    local $_ ;
    my $inpod  = 0 ;
    my $indent = 0 ;
    my $bullet ;

    foreach( @_ ) {
        $inpod = 1, next if /^=pod/o ;
        $inpod = 0, next if /^=cut/o ;
        next unless $inpod ;
        next if /^#/o ;

        &body( "\n" ), next if /^$/o ;

        if( /^=head1 (.*)/o ) {
            &head1( "$1\n\n" ) ;
        }
        elsif( /^=head2 (.*)/o ) {
            &head2( "$1\n\n" ) ;
        }
        elsif( /^[ \t]/o ) {
            &code( $_ ) ; # Verbatim.
        }
        elsif( /^=over/o ) {
            $indent = 1 ;
        }
        elsif( /^=back/o ) {
            $indent = 0 ;
            $bullet = undef ;
        }
        elsif( /^=item(?:\s+(\S))?/o ) {
            if( not defined $bullet ) { # Starting a new list.
                $bullet = $1 ? $1 : '*' ;
            }
            elsif( $bullet =~ /^\d+$/o ) { # Bullet is numbered.
                ++$bullet ;
            }
            # else bullet so no text required.
            &body( "$bullet ", 'bold', 'indent' ) ;
        }
        else {
            my $tag = $indent ? 'indent' : undef ;
            s/\n/ /go unless /^[\t ]/o ;
            my @fragments = split /([BCI]<)([^>]+)>/, $_ ;
            if( scalar @fragments ) {
                while( 1 ) {
                    my $fragment = shift @fragments ; 
                    last unless defined $fragment ;
                    if( $fragment eq 'B<' ) {
                        &bold( shift @fragments, $tag ) ;
                    }
                    elsif( $fragment eq 'C<' ) {
                        &code( shift @fragments, $tag ) ;
                    }
                    elsif( $fragment eq 'I<' ) {
                        &italic( shift @fragments, $tag ) ;
                    }
                    else {
                        &body( $fragment, $tag ) ;
                    }
                }
                &body( "\n\n", $tag ) ;
            }
            else {
                &body( "$_\n\n", $tag ) ;
            }
        }
    }
}


sub head1  { $TextBox->insert( 'end', shift, [ 'head1',  @_ ] ) }
sub head2  { $TextBox->insert( 'end', shift, [ 'head2',  @_ ] ) }
sub code   { $TextBox->insert( 'end', shift, [ 'code',   @_ ] ) }
sub bold   { $TextBox->insert( 'end', shift, [ 'bold',   @_ ] ) }
sub italic { $TextBox->insert( 'end', shift, [ 'italic', @_ ] ) }
sub body   { $TextBox->insert( 'end', shift, [ 'body',   @_ ] ) }


sub set_text_tags {

    eval {
        $TextBox->tagConfigure( 'head1',
            -font    => "-*-helvetica-bold-r-normal-*-*-240-*-*-*-*-*",
            -justify => 'center',
            -wrap => 'word',
            ) ;
    } ;
    $TextBox->tagConfigure( 'head1', -foreground => 'darkblue' ) ;

    eval {
        $TextBox->tagConfigure( 'head2',
            -font => "-*-helvetica-bold-r-normal-*-*-180-*-*-*-*-*",
            -wrap => 'word',
            ) ;
    } ;
    $TextBox->tagConfigure( 'head2', -foreground => 'darkgreen' ) ;

    eval {
        $TextBox->tagConfigure( 'body',
            -font => "-*-times-medium-r-normal-*-*-180-*-*-*-*-*",
            -wrap => 'word',
            -tabs => [ '2c' ],
            ) ;
    } ;

    eval {
        $TextBox->tagConfigure( 'bold',
            -font => "-*-times-bold-r-normal-*-*-180-*-*-*-*-*",
            ) ;
    } ;

    eval {
        $TextBox->tagConfigure( 'italic',
            -font => "-*-times-medium-i-normal-*-*-180-*-*-*-*-*",
            ) ;
    } ;
 
    eval {
        $TextBox->tagConfigure( 'code',
            -font => "-*-lucidatypewriter-medium-r-normal-*-*-140-*-*-*-*-*",
            -tabs => [ '1c' ],
            ) ;
    } ;
    $TextBox->tagConfigure( 'code', 
        -font => 'fixed',
        -tabs => [ '1c' ],
        ) if $@ ;

    $TextBox->tagConfigure( 'indent', -lmargin1 => 20, -lmargin2 => 35 ) ;
}
 

1 ;

