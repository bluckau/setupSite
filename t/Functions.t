use strict;
use warnings;

use Test::More tests=>7; 
#use Test::Files;
use Test::File;
use File::Spec;
use lib::Functions;
use File::Copy;


#set the prefix
my $prefix="/tmp/perltests";
$ENV{'PREFIX'} = $prefix;



###BEGIN TESTS###

# Verify can be included with 'use'	
use_ok('Functions');
#

#
# Verify: can be included with "require"
require_ok( 'Functions' );
#

#
#Not going to write tests at this time for:
# enable_daemon
# disable_daemon
# restart_daemon
#

#
#Test gen_rev_zone
is(Functions::gen_rev_zone_name("192.168.1.124"), "1.168.192.in-addr.arpa", "gen_rev_zone_name successfully generates a reverse zone name");
#
#

#
#Test gen last octet
is(Functions::get_last_octet("128.22.66.66"),"66", "last octet is retrieved by get_last_octet");
#

#
#Test resolv.conf generation
Functions::setup_resolv; 
# Verify the resolv.conf file can be created
my $resolv_file = "$prefix/etc/resolv.conf";
file_contains_like($resolv_file , qr/^nameserver.*/mx);
#

#
#Test create virtual host file
my $name="Sam";
my $vhosts_file_name = "$prefix/etc/apache2/vhosts.d/$name.conf";
#

#
Functions::create_virtual_host($name);
#Currently testing the file exists
file_exists_ok($vhosts_file_name);
#

#
#Test setup_bind
$name = "Sally";
my $ip = "192.168.222.222";
Functions::setup_bind($name, $ip, 24);
file_exists_ok("$prefix/etc/named.d/$name");
#
