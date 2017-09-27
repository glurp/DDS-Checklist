### Presentation

Here a check list of all item which should be check when DDS do not work.

I use only UDP and UNICAST. So there are nothing here for Multicast and TCP usages.

Fell free to append your knowledge here (PR or issue).

 

### General Checklist 

This list should work for any os/langage/version of application.



1. ping each host with other
2. check firewall(s) : if necessary, create rules for specific port UDP of DDS, which are link to your domainId and participantId (sse end of this doc)
3. traceroute (or tracert) : check if the route is the good way between the 2 hosts, use traceroute with UDP and ICMP (traceroute usage depends of os)
4. ping with big packet : ``` ping -s 1500``` on linux, ``` ping -l 1500```  for windows
5. nddsping at each side, each way , with the domainId you use  :

> ``` nddsping -domaineId DD -peer other-ip  -publish ```
> ``` nddsping -domaineId DD -peer other-ip -subscribe```
>
> When DDSPING is good, you are on the way :)
>
> 

6. Check if DDS use the good IP interface (network card...) : tcpdump or netstat grep with PID of  nddsping process, see linux CL
7. each side, run a publisher (nddsping), check nddsspy:

> ```nddsspy -domaindId DD  -peer other-ip  -printsample -typeWidth 40 -Verbosity 2```



Now, DDS work with your domainID, so check application level :

1. Sorry but you must dispose of the tool "Admin console". check/play with a 
  ddsping subscribe and publisher (** please help me for a checklist with only ddsspy 
  and ethereal/tcpdump **).
2. run your app and Admin-console, same host AND distant host.... :
3. your process must be present : <host> ==> process : <pid>, if not, error in domain participant / QOS of domain, ip route, firewall...
4. on DDS Logical View, the domain should not be empty, only error should be "reader-only" or "writer-only"
5. if error, 
   1. check topic : name, type name, IDL on each side
   2. check partition list (select publisher or subscriber, see partition list filter at DDS Qoq view, )
   3. check all QOS, between writer(s) and reader(s)





### Checklist for Java participant

1. java parameters/code 

   1.  -Djava.library.path=/.../ndds.XXX/lib/x64Linux2.6gcc4.1.1jdk 
   2.  -XX:ParallelGCThreads=2 
   3.  -classpath :....nddsjava.jar:...


   ​

2. env define

   > export NDDS_DISCOVERY_PEERS=...   # if UNICAST udp usage
   >
   > export  NDDS_QOS_PROFLE=...xml 

3. Java code   
   1.  for UNICAST Only discovery, declare id in SOS file, or hard code it before participant creation :
    > ```PropertyQosPolicyHelper.add_property(qos.property, "dds.transport.UDPv4.multicast_enabled", "0", false);```
   2. Don't forget register_type foreach topic type
   3. If you are not sure of partitions names run without partition, observe them with Admin console, or use therreal/tcpdump ith RTSP plugin,
   4. If partition naming is complex, publish them on a general Topic, on a partition name fixed and simple, so you can see them with ddsspy,
      so users will discover partition name without use of Admin Console or rtps dump

### Checklist Windows



ping options end tracert options are different from POSIX system.

tracert use ICMP without options.





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

3. in /etc/hosts, the first declaration must be your public IP adresse (not the local loopback !)

4. check netstat, greping with the PID if your preocess
    > pgrep -laf YOURPORCNAME
    >
    > netstat -anp | grep PID

Exemple (domainId=11):

>pgrep -laf **Runneur**
>
>21306 java -Djava.... appliserveur**.Runneur** -xml config/appli_sim.xml -temp /tmp/vmdds
>
>netstat -anp | grep 21306

udp        0      0 0.0.0.0:34157           0.0.0.0:*                           21306/java          
udp        0      0 0.0.0.0:36826           0.0.0.0:*                           21306/java          
udp        0      0 0.0.0.0:10160           0.0.0.0:*                           21306/java          
udp        0      0 0.0.0.0:10161           0.0.0.0:*                           21306/java          
udp        0      0 0.0.0.0:48763           0.0.0.0:*                           21306/java    



Here 10160 and 10161 are UDP port for DDS discovery and DDS data (no for domainId=11, participantId=0).
please, check if the IP correspond to the interface wich is on the good IP route....



UDP Ports number depend on domainId and participantId, and using Multicast or not:

Multicast:

> portDiscovery =7400+ 250 * domainId + 2 * participantId
>
> portData= portDiscovery+1

Unicast:

> 
>
> portDiscovery  = 7400 + 250 * domainId + 2* participantId + 10
>
> portData= portDiscovery+1



Max 250 Participants on one Host (or less, depend of implementation) ....



 References
---



UDP_Ports_Used_by_RTI_Connext_DDS.xls

....



### License

free, as libre :)

