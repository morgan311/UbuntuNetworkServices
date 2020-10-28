; BIND reverse data file for empty rfc1918 zone
;
;
$TTL	86400
@	IN	SOA	ns.morgan.com. root.morgan.com. (
			    123		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			  86400 )	; Negative Cache TTL
;
@	IN	NS	ns.morgan.com.
ns	IN	A	10.0.0.250
sysninja	IN	A	10.0.0.10
accounting	IN	A	10.0.0.20
*	IN	A	10.10.10.10
