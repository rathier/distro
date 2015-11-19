# See bottom of file for license and copyright information
package Foswiki;

use strict;
use warnings;

BEGIN {
    if ( $Foswiki::cfg{UseLocale} ) {
        require locale;
        import locale();
    }
}

sub URLPARAM {
    my ( $this, $params ) = @_;
    my $param     = $params->{_DEFAULT} || '';
    my $newLine   = $params->{newline};
    my $encode    = $params->{encode} || 'safe';
    my $multiple  = $params->{multiple};
    my $separator = $params->{separator};
    my $default   = $params->{default};
    my $validate  = $params->{validate};

    $separator = "\n" unless ( defined $separator );

    my $value = '';
    if ( $this->{request} ) {
        if ( Foswiki::isTrue($multiple) ) {
            my @valueArray = $this->{request}->multi_param($param);
            if (@valueArray) {

                # join multiple values properly
                unless ( $multiple =~ m/^on$/i ) {
                    my $item = '';
                    @valueArray = map {
                        $item = $_;
                        $_    = $multiple;
                        $_ .= $item unless (s/\$item/$item/g);
                        expandStandardEscapes($_)
                    } @valueArray;
                }

                # SMELL: the $separator is not being encoded
                $value = join(
                    $separator,
                    map {
                        _handleURLPARAMValue( $_, $newLine, $encode, $default,
                            $validate )
                    } @valueArray
                );
            }
            else {
                $value = $default;
                $value = '' unless defined $value;
            }
        }
        else {
            $value = $this->{request}->param($param);
            $value =
              _handleURLPARAMValue( $value, $newLine, $encode, $default,
                $validate );
        }
    }
    return $value;
}

sub _handleURLPARAMValue {
    my ( $value, $newLine, $encode, $default, $validate ) = @_;

    $value = _validateValue( $value, $validate )
      if ( defined $value && defined $validate );

    if ( defined $value ) {
        $value =~ s/\r?\n/$newLine/g if ( defined $newLine );
        foreach my $e ( split( /\s*,\s*/, $encode ) ) {
            if ( $e =~ m/entit(y|ies)/i ) {
                $value = entityEncode($value);
            }
            elsif ( $e =~ m/^quotes?$/i ) {
                $value =~
                  s/\"/\\"/g; # escape quotes with backslash (Bugs:Item3383 fix)
            }
            elsif ( $e =~ m/^url$/i ) {

                # Legacy, see ENCODE
                #$value =~ s/\r*\n\r*/<br \/>/;
                $value = urlEncode($value);
            }
            elsif ( $e =~ m/^safe$/i ) {

                # entity encode ' " < > and %
                $value =~ s/([<>%'"])/'&#'.ord($1).';'/ge;
            }
        }
    }
    unless ( defined $value ) {
        $value = $default;
        $value = '' unless defined $value;
    }

    # Block expansion of %URLPARAM in the value to prevent recursion
    $value =~ s/%URLPARAM\{/%<nop>URLPARAM{/g;
    return $value;
}

sub _validateValue {
    my ( $value, $validate ) = @_;

    my ( $method, $validation ) = split( ':', $validate, 2 );
    $value = _validateHandler( $method, $validation, $value );

    return $value;
}

sub _validateHandler {
    my ( $method, $validation, $value ) = @_;

    eval 'use Foswiki::ValidationHandler::' . $method . ' ()';
    if ($@) {
        return "MISSING validation method: $method";
    }
    else {
        my $handler   = 'Foswiki::ValidationHandler::' . $method;
        my %checkOpts = $handler->options();
        print STDERR Data::Dumper::Dumper( \%checkOpts );
        my %valOptions = _CHECK( $validation, %checkOpts )
          if ( defined $validation );

        return $handler->VALIDATE( $value, \%valOptions );
    }
}

# This code is shamelessly borrowed from Configure::Value
# Validation options are:
# HANDLER:option option:value option:value,value option:'value', where
#    * each option has a value (the default when just the keyword is
#      present is 1)
#    * options are separated by whitespace
#    * values are introduced by : and delimited by , (Unless quoted,
#      in which case there is just one value.  N.B. If quoted, double \.)
#    * Generated an arrayref containing all values for
#      each option
# The %CHECK_options hash is provided by the particular checker.
#

sub _CHECK {
    my ( $str, %CHECK_options ) = @_;

    my %validated;

    my $ostr = $str;
    $str =~ s/^(["'])\s*(.*?)\s*\1$/$2/;

    my %valOptions;
    while ( $str =~ s/^\s*([a-zA-Z][a-zA-Z0-9]*)// ) {
        my $name = $1;
        my $set  = 1;
        if ( $name =~ s/^no//i ) {
            $set = 0;    # negated option
        }
        throw Foswiki::OopsException(
            'params',
            def    => 'CHECK_parse_unrecognized',
            params => [ $name, $ostr ]
        ) unless ( defined $CHECK_options{$name} );

        my @opts;
        if ( $str =~ s/^\s*:\s*// ) {
            do {
                if ( $str =~ s/^(["'])(.*?[^\\])\1// ) {
                    push( @opts, $2 );
                }
                elsif ( $str =~ s/^([-+]?\d+)// ) {
                    push( @opts, $1 );
                }
                elsif ( $str =~ s/^([a-z_{}]+)//i ) {
                    push( @opts, $1 );
                }
                else {
                    throw Foswiki::OopsException(
                        'params',
                        def    => 'CHECK_parse_notalist',
                        params => [ $str, $ostr ]
                    );
                }
            } while ( $str =~ s/^\s*,\s*// );
        }
        if ( $CHECK_options{$name} >= 0
            && scalar(@opts) != $CHECK_options{$name} )
        {
            die
"CHECK parse failed: wrong number of params to '$name' (expected $CHECK_options{$name}, saw @opts)";
        }
        if ( !$set && scalar(@opts) != 0 ) {
            die "CHECK parse failed: 'no$name' is not allowed";
        }
        if ( scalar(@opts) == 0 ) {
            $valOptions{$name} = $set;
        }
        else {
            $valOptions{$name} = \@opts;
        }
    }
    throw Foswiki::OopsException(
        'params',
        def    => 'CHECK_parse_expectname',
        params => [ $str, $ostr ]
    ) if $str !~ /^\s*$/;

    return %valOptions;
}

1;
__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Copyright (C) 2008-2015 Foswiki Contributors. Foswiki Contributors
are listed in the AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

Additional copyrights apply to some or all of the code in this
file as follows:

Copyright (C) 1999-2007 Peter Thoeny, peter@thoeny.org
and TWiki Contributors. All Rights Reserved. TWiki Contributors
are listed in the AUTHORS file in the root of this distribution.
Based on parts of Ward Cunninghams original Wiki and JosWiki.
Copyright (C) 1998 Markus Peter - SPiN GmbH (warpi@spin.de)
Some changes by Dave Harris (drh@bhresearch.co.uk) incorporated

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.
