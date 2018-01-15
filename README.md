### Presentation

Here a check list of all item which should be check when DDS do not work.

I use only UDP and UNICAST. So there are nothing here for Multicast and TCP usages.

Fell free to append your knowledge here (PR or issue).

### Know the UDP Port used

UDP Ports number depend on domainId and participantId, and using Multicast or not:

Participant ID is 0 for the first participant running on the host, 1 for the second (ddsspy, by exemple) 2 for the third (AdminTool) ...

Max of 250/2=125 participants by host (for one domainId).



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

You should see your application with netstat :

> DomainId= 11 ==> base port number == 7400+10+250*11 ==> 10160
>
> netstat -anp | grep   :1016

udp        0      0 0.0.0.0:10160           0.0.0.0:*                           21306/java          
udp        0      0 0.0.0.0:10161           0.0.0.0:*                           21306/java          



#### System checks



1. ping each host with other
2. check firewall(s) : if necessary, create rules for specific port UDP of DDS, which are link to your domainId and participantId (see ports numbers)
3. traceroute (or tracert) : check if the route is the good way between the 2 hosts, use traceroute with UDP and ICMP (traceroute usage depends of os)
4. ping with big packet : ``` ping -s 1500``` on linux, ``` ping -l 1500```  for windows
5. check system time on each participant host, use ntp for synchronize all host !



#### DDS installations checks



1. nddsping at each side, each way , with the domainId you use  :

> ``` nddsping -domaineId DD -peer other-ip  -publish ```
> ``` nddsping -domaineId DD -peer other-ip -subscribe```
>
> 
>
> When DDSPING is good, you are on the way :), else, realy, check  yours firewalls...
>
> 

6. Check if your application DDS use the good IP interface (network card...) : tcpdump or netstat grep with PID of  nddsping process, see linux CL
7. Check ddsspy : each side, run a publisher (nddsping), and then check if nddsspy see the pingers:

> ```nddsspy -domaindId DD  -peer other-ip  -printsample -typeWidth 40 -Verbosity 2```



#### DDS Application check



Now, DDS work with your domainID, tools like ddsping and ddsspy works, so check application level. 

Sorry but you must dispose of the tool "**Admin console**" at this point.

* check topics data (samples) use ddsspy
* check publish/subscribe visibility, and QOS Rox : Admin tool. (without admin tool, its becom difficult to diagnostic Rox issues, see listeners callback)



1. Learn admin console : Check/play with a ddsping 

2. learn to interpret ddsspy :

   ```
   V time        data V     V IP publisher  V topic name    V typeinfo name
   1506532677.023221  D +M  0ACB4CCA        Mssss            PACK::INFOName           

   idObjet: "EQP_VENT2"                          |
   idInfo: 1002                                  | the sample data 
   timestamp: 1506532674649000                   |
   value: 47                                     | 

   ```

   ​

3. In your App, enable all properties of your listeners, and print a log on each callback of each listener :

   (see java part)

4. Run your app and Admin-console, same host AND distant host.... :

5. Your process must be present in Admin-console : <host> ==> process : <pid>, if not, error in domain participant / QOS of domain, ip route, firewall...

6. on DDS Logical View, the domain should not be empty, only error should be "reader-only" or "writer-only". If domain is empty, there are issue with the UDP dataPort (discoveryPort ok, but not dataPort)

7. if error, 
   1. check topic : name, type name, IDL on each side
   2. check partition list (in Admin console, select publisher or subscriber, see partition list filter at DDS Qos view on subscriber, see real partition name on publisher side )
   3. check all QOS, between writer(s) and reader(s) : if there are errors, Admin-Consol will show error (Health and Match-Analyses  pad)





### Checklist for Java participant

1. java parameters/code 

   1.  -Djava.library.path=/.../ndds.XXX/lib/x64Linux2.6gcc4.1.1jdk 
   2.  -XX:ParallelGCThreads=2 
   3.  -classpath :....nddsjava.jar:...


   

2. env define

   > export NDDS_DISCOVERY_PEERS=...   # if UNICAST udp usage
   >
   > export  NDDS_QOS_PROFLE=...xml 

3. Java code   
   1.  for UNICAST Only discovery, declare id in OS file, or hard code it before participant creation :
    > ```PropertyQosPolicyHelper.add_property(qos.property, "dds.transport.UDPv4.multicast_enabled", "0", false);```
   2. If you are not sure of partitions names run without partition, observe them with Admin console, or use wireshark/tcpdump with RTSP plugin,
   3. If partition naming is complex, publish them on a general Topic, on a partition name fixed and simple, so you can see them with ddsspy,
      so users will discover partition name without use of Admin Console or rtps dump

Example for StatusKind settings (to be confirm by an expert !)  :

```java
Subscriber subscriber = participant.create_subscriber(
            subQos, 
            new GSubscriberListener(),
            StatusKind.INCONSISTENT_TOPIC_STATUS|
            StatusKind.REQUESTED_INCOMPATIBLE_QOS_STATUS|					
             0
);
    
     
DataReader dr=subscriber.create_datareader_with_profile(topic,
            "...",
            profileName, 
            drListener,
            StatusKind.DATA_AVAILABLE_STATUS|
            StatusKind.DATA_ON_READERS_STATUS|
            StatusKind.DATA_READER_PROTOCOL_STATUS|
            StatusKind.DDS_DATA_READER_CACHE_STATUS|
            StatusKind.RELIABLE_READER_ACTIVITY_CHANGED_STATUS|
            StatusKind.REQUESTED_INCOMPATIBLE_QOS_STATUS|
0); 
Publisher publisher = participant.create_publisher(
        pqos,
        pubListener, 
        StatusKind.OFFERED_DEADLINE_MISSED_STATUS|
        StatusKind.LIVELINESS_LOST_STATUS|
        StatusKind.OFFERED_INCOMPATIBLE_QOS_STATUS|
        StatusKind.PUBLICATION_MATCHED_STATUS|
        StatusKind.RELIABLE_WRITER_CACHE_CHANGED_STATUS|
        StatusKind.RELIABLE_READER_ACTIVITY_CHANGED_STATUS|
0);


DataWriter dw  = publisher.create_datawriter_with_profile(topic,
        "...",
        profileName,
        dwListener,
        StatusKind.DATA_WRITER_APPLICATION_ACKNOWLEDGMENT_STATUS|
        StatusKind.DATA_WRITER_INSTANCE_REPLACED_STATUS|
        StatusKind.DATA_WRITER_SAMPLE_REMOVED_STATUS|
        StatusKind.OFFERED_INCOMPATIBLE_QOS_STATUS|
0);
```



### Checklist Windows



ping options end tracert options are different from POSIX system.

tracert use ICMP without options.





### Checklist Linux

1. Kernel tuning if using multiple participant on same host. Here a example with CENTOS7, 100 participants) :

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





###  



### License

free, as libre :)

