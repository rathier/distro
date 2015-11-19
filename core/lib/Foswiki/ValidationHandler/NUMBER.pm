# See bottom of file for license and copyright information
package Foswiki::ValidationHandler::NUMBER;

# Default checker for NUMBER items
#
# CHECK options in spec file
#  CHECK="option option:val option:val,val,val"
#    radix: (2-36), specified in decimal.
#    min: value in specified radix
#    max: value in specified radix
#    undefok
#
# Use this checker if possible; otherwise subclass the item-specific checker from it.

use strict;
use warnings;

# Legal options for a CHECK. The number indicates the number of expected
# parameters; -1 means '0 or more'
my %CHECK_options = (
    max     => 1,    # max value
    min     => 1,    # min value
    integer => 0,    # Wants an integer 1
    decimal => 0,    # Wants a decimal  1.2
    float   => 0,    # Wants a floating number
);

sub options {
    return %CHECK_options;
}

sub VALIDATE {
    my ( $this, $value, $validation ) = @_;

    print STDERR "VALIDATE called with ($value) : "
      . Data::Dumper::Dumper( \$validation );

    if ( $value !~ /^\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?\s*$/ ) {
        return "Number format error";
    }
    if (   $validation->{integer}
        || $validation->{decimal}
        || $validation->{float} )
    {
        if ( $value =~ m/^[0-9]+$/ ) {
            die "Integer not allowed" unless ( $validation->{integer} );
        }
        elsif ( $value =~ m/^[0-9]*\.[0-9]+$/ ) {
            die "decimal not allowed" unless ( $validation->{decimal} );
        }
        else {
            die "float not allowed" unless ( $validation->{float} );
        }
    }

    my $min = $validation->{min}[0];
    if ( defined $min ) {
        die "Value must be at least $min"
          if ( $value < $min );
    }

    my $max = $validation->{max}[0];
    if ( defined $max ) {
        die "Value must no more than $max"
          if ( $value > $max );
    }

    return $value;
}

1;
__END__

    my $max = $this->{item}->CHECK_option('max');
    if ( defined $max ) {
        $reporter->ERROR("Value must be no greater than $max")
          if ( $val > $max );
    }
}
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Copyright (C) 2008-2015 Foswiki Contributors. Foswiki Contributors
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
