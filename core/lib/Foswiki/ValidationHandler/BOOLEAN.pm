# See bottom of file for license and copyright information

=begin TML

---+ package Foswiki::ValidationHandler:BOOLEAN

This package is designed to be lazy-loaded when Foswiki sees
an INCLUDE macro with the http: protocol. It implements a single
method INCLUDE. Also handles https:

=cut

package Foswiki::ValidationHandler::BOOLEAN;

use strict;
use warnings;

use Foswiki ();
use Foswiki::Func();

BEGIN {
    if ( $Foswiki::cfg{UseLocale} ) {
        require locale;
        import locale();
    }
}

# Legal options for a CHECK. The number indicates the number of expected
# parameters; -1 means '0 or more'
my %CHECK_options = ();

sub options {
    return %CHECK_options;
}

sub VALIDATE {

    #my ( $this, $value, $validation ) = @_

    return Foswiki::Func::isTrue( $_[1] );
}

1;
__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Copyright (C) 2008-2015 Foswiki Contributors. Foswiki Contributors
are listed in the AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.
