package Functions;
use strict;
use Network::IPv4Addr qw( :all );

sub enable_daemon
{
	my $daemon = shift;
	system("/usr/bin/systemctl", "enable",$daemon);
	system("/usr/bin/systemctl", "start",$daemon);
}

sub disable_daemon
{
	my $daemon = shift;
	system("/usr/bin/systemctl", "disable",$daemon);
	system("/usr/bin/systemctl", "stop",$daemon);
}

sub restart_daemon
{
	my $daemon = shift;
	system("/usr/bin/systemctl", "restart",$daemon);

}

sub gen_rev_zone_name 
{
	my $ip = shift;
	my ($a,$b,$c,$d)=split /\./, $ip;
	my $reverse_zone_name=join '.', $c, $b, $a, "in-addr", "arpa";
	return $reverse_zone_name;
}

sub gen_network_addr
{
	my $ip=shift;
	my $maskbits=shift;
	return ipv4_parse("$ip/$maskbits");
}
sub get_last_octet
{
        my $ip = shift;
        my ($a,$b,$c,$d)=split /\./, $ip;
        return $d;
}




return 1;

