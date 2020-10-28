# Network Services using Ubuntu 20.04.1 LTS

Weccome to my Netowrk Services using Ubuntu server repositoty! For this setup I have created an applicance (virtually) running Ubuntu 20.04.1 LTS in conjunction with very important network services no server should be without! these services inclue **DNS**, **DHCP** ,**UFW Firewall**, and **Squid Proxy**.

## Distro Install ##

There are a few items needed to set this applicance up, in this instacne i used VMware and Ubuntu server 20.04.1 if you dont have VMware Vbox will work grab them here
* https://releases.ubuntu.com/20.04/
* https://www.virtualbox.org/wiki/Downloads

Default system specs should work fine, I would suggest to initially select **NAT** network then after add an additional NIC for your LAN. As well the PowerShell snap might be a useful add-on. 


## DNS w/Bind ##

Bind9 is an opens source domain name system server that can be used to run a caching or authoritative name server.

**Installiation:**
* sudo apt-get install bind9 bind9utils bind9-doc

**Primary Master Server Configuration**
Adding a DNS zone to bind will allow it to act as a Primary Master server. To do so first edit **named.conf.local** locaed in /etc/bind must be edited.

Add desired Zone name and zone file path.

        zone "morgan.com" {
             type master;
             file "/etc/bind/db.morgan.com";
        };
        
Copy and rename existing db.local file
* sudo cp /etc/bind/db.local /etc/bind/db.morgan.com 
Next edit the zone file you created /etc/bind/db.morgan.com
* Change the SOA from localhost. to FQDM of server ns.morgam.com. <---make sure there is a period after the FQDN
* Set valid email address using **.** in replace of @ root.morgan.com.
* Replace NS localhost. with FQDN of server
* Create A record for your name server with servers IP address

**NOTE-Ensure you select the correct network, your private network should be entered here**

<img src="https://i.imgur.com/pBnK00V.jpg"/>

* Restart bind server: Sudo service bind9 restart
* Check status Sudo service bind9 status
Basic set up should be complete! Test via client or with the dig @ command on the server.

## DCHP ##

Tired of boring static ip address? Install a DHCP server!

**Installiation**

* sudo apt-get install isc-dhcp-server

**Configuration**

Main config file located ub /etc/dhcp/, open dhcpd.conf in nano and configure to align with your server info

* sudo nano /etc/dhcp/dhcpd.conf


        default-lease-time 600;
        max-lease-time 7200;
        subnet 10.0.0.0 netmask 255.255.255.0 {
        range 10.0.0.100 10.0.0.150;
        range 10.0.0.200 10.0.0.225
        option domain-name "morgan.com";
        option domain-name-servers ns.morgan.com;
        
} 

Above are the minimum configurations, enter subnet and mask of your network then enter desired ranges, in this instance the dhcp server will issus IP addresses in two ranges 10.0.0.100-150 and 10.0.0.200-225

Next configure DHCP to only issed adddress on your private network
* sudo nano /etc/default/isc-dhcp-server
* INTERFACESv4="ens33"  <--private network nic


