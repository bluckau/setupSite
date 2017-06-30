# setupSite
Perl scripts to set up a virtual host in apache and corresponding DNS entries.

Usage is setupSite.pl <name> <ip> <subnet mask bits>

Example:

# setupSite.pl examplesite 10.0.1.200 16


Possible enhancements:
* Support more than OpenSuSE Tumbleweed
* Make parameters configurable
* Open ports in the firewall specifically for apache and DNS
