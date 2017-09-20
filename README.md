### Presentation

Here a check list of all item which should be check when DDS do not work.

I use only UDP and UNICAST. So there are nothing here for Multicast and TCP usages.

Fell free to append your knowledge here (PR or issue).

 

### General Checklist 

This list should work for any os/langage/version of application.



1. ping each host with other
2. check firewall(s) : rules are specifique to UDP port, which are link to your domainId and participantId
3. traceroute (or tracert) : check if the route is the good way between the 2 hosts
4. ping with big packet : ``` ping -s 1500``` on linux, ``` ping -l 1500```  for windows
5. nddsping at each side, each way , with the domainId you use  :

> ``` nddsping -domaineId DD -peer other-ip  -publish ```
> ``` nddsping -domaineId DD -peer other-ip -subscribe```

6. Check if DDS use the good IP interface (network card...) : tcpdump or netstat greped with PID of  nddsping process, see linux CL
7. each side, run a publisher (nddsping), check nddsspy:

> ```nddsspy -domaindId DD  -peer other-ip  -printsample -typeWidth 40 -Verbosity 2```



Now, RTI DDS work with your domainID, so check application level :

1. Sorry but you must dispose of the tool "RTI Admin console". check/play with a 
ddsping subscribe and publisher (**please help me for a checklist with only ddsspy 
and ethereal/tcpdump**).
2. run your app and Admin-console, same host AND distant host.... :
4. your process must be present : <host> ==> process : <pid>, if not, error in domain participant / QOS of domain, ip route, firewall...
5. on DDS Logical View, the domain should not be empty, only error should be "reader-only" or "writer-only"
6. if error, 
   1. check topic : name, type name, IDL on each side
   2. check partition list (select publisher or subscriber, see partition list filter at DDS Qoq view, )
   3. check all QOS, between writer(s) and reader(s)





### Checklist for Java participant

1. java parameters 

   1.  -Djava.library.path=/.../RTI/ndds.XXX/lib/x64Linux2.6gcc4.1.1jdk 
   2.  -XX:ParallelGCThreads=2 
   3.  -classpath :....nddsjava.jar:...
   4.  for UNCAST Only discovery :
    > ```PropertyQosPolicyHelper.add_property(qos.property, "dds.transport.UDPv4.multicast_enabled", "0", false);```
   

   ​

2. env define

   > export NDDS_DISCOVERY_PEERS=...   # if UNCAST udp usage
   > export  NDDS_QOS_PROFLE=...xml 

   ​



### Checklist Windows

?



### Checklist Linux

1. Kernel tuning if using multiple participant on same host. Here a exemple with CENTOS7, 100 participants) :

   > sysctl -w kernel.shmmax=173741824
   >
   > sysctl -w kernel.shmmni=2048
   >
   > sysctl -w kernel.shmall=262144
   >
   > sysctl -w kernel.sem=1000 6400 200 1048
   >
   > echo 50000 > /proc/sys/kernel/threads-max

2. check with ```ipcs -l```

3. in /etc/hosts, the first declaration must be your public IP adresse (no local loopback !)

4. check netstat, greping with the PID if your preocess
    > pgrep -laf YOURPORCNAME
    >
    > netstat -anp | grep PID

Exemple:

>pgrep -laf Runneur
>
>21306 java -Djava.... appliserveur.Runneur -xml config/appli_sim.xml -temp /tmp/vmdds
>
>netstat -anp | grep 21306

udp        0      0 0.0.0.0:34157           0.0.0.0:*                           21306/java          
udp        0      0 0.0.0.0:36826           0.0.0.0:*                           21306/java          
udp        0      0 0.0.0.0:10160           0.0.0.0:*                           21306/java          
udp        0      0 0.0.0.0:10161           0.0.0.0:*                           21306/java          
udp        0      0 0.0.0.0:48763           0.0.0.0:*                           21306/java    

Here 10160 and 10161 are UDP port for DDS discovery and DDS data.
please, check if the IP correspond to the interface wich is on the good IP route....


### References

?

### License

free, as libre :)

