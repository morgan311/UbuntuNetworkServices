# Network Services using Ubuntu 20.04.1 LTS

Welcome to my Network Services using Ubuntu server repository! For this setup I have created an appliance (virtually) running Ubuntu 20.04.1 LTS in conjunction with very important network services no server should be without! these services include **DNS**, **DHCP** ,**UFW Firewall**, and **Squid Proxy**.

## Distro Install ##

There are a few items needed to set this appliance  up, in this instance I used VMware and Ubuntu server 20.04.1 if you dont have VMware Vbox will work grab them here
* https://releases.ubuntu.com/20.04/
* https://www.virtualbox.org/wiki/Downloads

Default system specs should work fine, I would suggest to initially select **NAT** network then after add an additional NIC for your LAN. As well the PowerShell snap might be a useful add-on. 


## DNS w/Bind ##

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

## DCHP ##

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

## FIREWALL W/UFW and Masquerading ##

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

**Note: There are thousnds of lines in the squid.conf configuration file, I recommend using copying the original file and manipulate the copy on something like Notepad++ or your favorite text editor**


