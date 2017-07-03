#!/usr/bin/perl

#  119  2017-06-28 10:36:40 zypper install apache2-devel apache2-mod_perl
#  123  2017-06-28 10:38:14 zypper install bind bind-utils

use strict;
use warnings;
use lib::Functions;

my $APACHE_VHOSTS_DIR="/etc/apache2/vhosts.d/";
my $BIND_DIR="/etc/named.d/";
my $ZONE_DIR= "/var/lib/named/";
my $prefix = $ENV{'PREFIX'};


my($name, $ip_addr, $maskbits) = @ARGV;

if (not defined $name) {
	die "Need a name";
}

if (not defined $ip_addr) {
	die "Need an IP address.";
}

if (not defined $maskbits) {
	print ( "Default to 16 bit netmask");
	$maskbits=16
}	

my $vhosts_file="$APACHE_VHOSTS_DIR/$name.conf";
my $dns_file=$BIND_DIR.$name;



sub main
{

        #TODO: need to open ports instead of disabling the firewall
	Functions::disable_daemon("SuSEfirewall2_init");
	Functions::disable_daemon("SuSEfirewall2");

	Functions::enable_daemon("apache2");
	Functions::create_virtual_host($name);
        Functions::restart_daemon("apache2");
	
	Functions::enable_daemon("named");
	Functions::setup_bind($name, $ip_addr, $maskbits);
	Functions::setup_resolv($name);
	Functions::restart_daemon("named");
}

main;

