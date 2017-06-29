use strict;
use warnings;
use Test::More qw(no_plan);
# Verify can be included with 'use'	
BEGIN { use_ok('Functions') };

# Verify: can be included with "require"
require_ok( 'HelloPerlBuildWorld' );


