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


