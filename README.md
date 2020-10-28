 <center># Network Services using Ubuntu 20.04.1 LTS #</center>

# Table of Contents
- [Intro](#Intro)
- [Distro Install](#Distro-Install)
- [DNS Bind9](#DNS-Bind9)
- [DHCP](#DHCP)
- [Uncomplicated Firewall](#FIREWALL-ufW-and-Masquerading)
- [Squid Proxy](#SQUID)

---

# Intro #

Welcome to my Network Services using Ubuntu server repository! For this setup I have created an appliance (virtually) running Ubuntu 20.04.1 LTS in conjunction with very important network services no server should be without! these services include **DNS**, **DHCP** ,**UFW Firewall**, and **Squid Proxy**.

## Distro Install ##

There are a few items needed to set this appliance  up, in this instance I used VMware and Ubuntu server 20.04.1 if you dont have VMware Vbox will work grab them here
* https://releases.ubuntu.com/20.04/
* https://www.virtualbox.org/wiki/Downloads

Default system specs should work fine, I would suggest to initially select **NAT** network then after add an additional NIC for your LAN. As well the PowerShell snap might be a useful add-on. 


## DNS Bind9 ##

Bind9 is an opens source domain name system server that can be used to run a caching or authoritative name server.

**Installation**
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

## DHCP

Tired of boring static ip address? Install a DHCP server!

**Installation**

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

Above are the minimum configurations, enter subnet and mask of your network then enter desired ranges, in this instance the dhcp server will issue IP addresses in two ranges 10.0.0.100-150 and 10.0.0.200-225

Next configure DHCP to only issue addresses on your private network
* sudo nano /etc/default/isc-dhcp-server
* INTERFACESv4="ens33"  <--private network nic
* restart service and confirm client is getting ip from server

## FIREWALL UFW and Masquerading ##

Uncomplicated Firewall is front-end to iptables designed to make firewall management more user friendly and has a nifty NAT capabilities

**INSTALLIATION **

* sudo apt-get install ufw
* ufw must be enabled - sudo wfw enable

**ADDING RULES**

Some examples of adding rules

* sudo ufw allow 22  <-- open SSH port
* sudo ufw deny 22
* sudo ufw allow proto tcp from 192.168.1.100 to any port 22  <-- allow specific host to SSH
* active rules can be checked with - sudo ufw status

**MASQUERADING**

Masquerading will allow your private machines connect to the internet via your server, some configuration is required

* enable packet forwarding - sudo nano /etc/default/ufw
* edit DEFUALT_FORWARD_POLICY="**ACCEPT**"
* next edit /etc/ufw/sysctl.conf
* uncomment net/ipv4/ip_forward=1 **uncomment ipv6 is desired**

Next we must configure the NAT table in the /etc/ufw/before.rules file, add the following below header comments


        # nat Table rules
        *nat
        :POSTROUTING ACCEPT [0:0]

        # Forward traffic from ens38 through ens33.
        -A POSTROUTING -s 10.0.0.0/24 -o ens33 -j MASQUERADE

        # don't delete the 'COMMIT' line or these nat table rules won't be processed
        COMMIT

We are appending the post route to forward traffic from our private network out our public nic to the world wide web!

Lastly, disable and re-enable UFW to apply settings
* sudo ufw disable && sudo ufw enable
* check on private client machine if you can reach the outside world

## SQUID ##

Squid is a caching and forwarding web proxy with a multitude of uses. 

**Note: There are thousnds of lines in the squid.conf configuration file, I recommend copying the original file and manipulate the copy until you get it right on something like Notepad++ or your favorite text editor**
* sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.original

**INSTALLIATION**
* sduo apt-get install squid

**CONFIGURATION**

Configure squid by editing /etc/squid/squid.conf

chnage default listening port edit the http_port directive
* http_port 8888
* the on-disk cache can be adjusted by editing cache_dir for this setup defaults are fine
**NOTE - DONT FORGET TO OPEN PORT 8888 on your server!!**

set squid access control by configuring an ACL for your private network, add the following below the ACL section
* acl MP_NET src 10.0.0.0/24  <-- acl name / allowed addresses
        #ac
next in the http_access section add the following
* http_access allow MP_NET

Now we can set up some redirections of sites we do not want out users to access. To do so we need to create another ACL.

At the bottom of the ACL section of /etc/squid/squid.conf add the following two lines
* acl blocksites dstdomain .neverssl.com
* deny_info https://www.google.com all
**In the top line you can add the domains you wish to block

At the top of the http_access section add the following line **above** your allow statement 
* http_reply_access deny blocksites all

Next we need to set up the proxy to act transparently, to do so we need to add a new rule to our /etc/ufw/befor.rules
* sudo nano /etc/ufw/before.rules
Add the following rule in the NAT table

      # nat Table rules
        *nat
        :POSTROUTING ACCEPT [0:0]
        # redirect to squid
        -A PREROUTING-p TCP -s 10.0.0.0/24 --dport 80 -j REDIRECT --to-port 8888
        

Lastly confirm that client machine cannot connect the **blockedsites** list!

**Thanks for checking out my Network Services on Ubuntu server repo! Check the folder for my configuration files!

