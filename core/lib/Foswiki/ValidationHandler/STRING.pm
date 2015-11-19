# See bottom of file for license and copyright information
package Foswiki::ValidationHandler::STRING;

# Default checker for STRING items
#
# CHECK options in spec file
#  CHECK="option option:val option:val,val,val"
#    min: length
#    max: length
#    accept: regexp,regexp
#            If present, must match one
#    filter: regexp, regexp
#            If present, any match fails
# Use this checker if possible; otherwise subclass the
# item-specific checker from it.

use strict;
use warnings;

use Assert;

# Legal options for a CHECK. The number indicates the number of expected
# parameters; -1 means '0 or more'
my %CHECK_options = (
    max    => 1,     # max value
    min    => 1,     # min value
    accept => -1,    # Regular expression, matching values are returned
    filter => -1,    # Regular expression, matching values throws error
);

sub options {
    return %CHECK_options;
}

sub VALIDATE {
    my ( $this, $value, $validation ) = @_;

    return unless defined $value;

    my $len = length($value);

    my $min = $validation->{min}[0];
    my $max = $validation->{max}[0];

    my $accept = $validation->{accept};
    my $filter = $validation->{filter};

    if ( defined $min && $len < $min ) {
        throw Foswiki::OopsException(
            'params',
            def    => 'min_length_error',
            params => [ 'blah', $min ]
        );
    }
    elsif ( defined $max && $len > $max ) {
        throw Foswiki::OopsException(
            'params',
            def    => 'max_length_error',
            params => [ 'blah', $max ]
        );
    }
    else {
        my $ok = 1;
        if ($accept) {
            $ok = 0;
            foreach my $are (@$accept) {
                if ( $value =~ $are ) {
                    $ok = 1;
                    last;
                }
            }
        }
        unless ($ok) {
            throw Foswiki::OopsException(
                'params',
                def    => 'accept_rule_failed',
                params => [ 'blah', join( "\n", @$accept ) ]
            );
        }

        if ( $ok && $filter ) {
            foreach my $fre (@$filter) {
                if ( $value =~ $fre ) {
                    $ok = 0;
                    last;
                }
            }
        }
        unless ($ok) {
            throw Foswiki::OopsException(
                'params',
                def    => 'filter_rule_failed',
                params => [ 'blah', join( "\n", @$filter ) ]
            );
        }
    }
    return $value;
}

1;
__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Copyright (C) 2008-2014 Foswiki Contributors. Foswiki Contributors
are listed in the AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

Additional copyrights apply to some or all of the code in this
file as follows:

Copyright (C) 2000-2006 TWiki Contributors. All Rights Reserved.
TWiki Contributors are listed in the AUTHORS file in the root
of this distribution. NOTE: Please extend that file, not this notice.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.
