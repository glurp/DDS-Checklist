### Presentation

Here a check list of all item which should be check when DDS do not work.

I use only UDP and UNICAST. So there a nothing here for Multicast and TCP usages.

Fell free to append your knowledge here (PR or issue).

 

### General Checklist 

This list should work for any os/langage/version of application.



1. ping each host with other
2. check firewall(s)
3. traceroute (or tracert) : check if the route is the good way between the 2 host
4. ping with big packet : ``` ping -s 1500``` on linux, ``` ping -l 1500```  for windows
5. nddsping at each side, each way , with the domainId you use (DomainId and participantId determine 2 UDP port number) :

> ``` nddsping -domaineId DD -peer other-ip  -publish ```
>
> ```nddsping -domaineId DD -peer other-ip -subscribe```

4. with tcpdump/windump/etherreal , check if DDS use the good IP interface (network card...)
5. each side, run a publisher, check nddsspy:

> ```nddsspy -domaindId DD  -peer other-ip  -printsample -tupeWidth 40 -Verbosity 2```



Now, RTI DDS work with your domainID, so check application level :

1. Sorry but you must dispose of the tool "RTI Admin console". check/play with a ddsping subscribe and publisher (**please help me for a check -list only with ddsspy ant etherreal/tcpdump**).
2. run your app.
3. on Admin-console, same host AND distant host....
4. your process must be present : <host> ==> process : <pid>, if not, error in domain participant / QOS of domain, firewall...
5. on DDS Logical View, the domain should not be empty, only error are ''reader-only" or "writer-only"
6. if error, 
   1. check topic : name, type name, IDL on each side
   2. check partition list (select publisher or subscriber, see partition list filter at DDS Qoq view, )
   3. check all QOS, between writer(s) and reader(s)







### Checklist for Java participant

1. java parameters 

   1.  -Djava.library.path=/.../RTI/ndds.XXX/lib/x64Linux2.6gcc4.1.1jdk 
   2.  -XX:ParallelGCThreads=2   # is naturally too big on big server...
   3. -classpath :....nddsjava.jar:...

   ​

2. env define

   > export NDDS_DISCOVERY_PEERS=...
   >
   > export  NDDS_QOS_PROFLE=...xml 

   ​



### Checklist Windows

?



### Checklist Linux

1. Kernel tuning if using multiple participant on same host. Here a exemple with CENTOS7, 100 participants) :

   > sysctl -w kernel.shmmax=173741824
   > sysctl -w kernel.shmmni=2048
   > sysctl -w kernel.shmall=262144
   > bash -c 'echo 1000 6400 200 1048 > /proc/sys/kernel/sem'
   >
   > or
   >
   > sysctl -w kernel.sem=1000 6400 200 1048
   >
   > echo 50000 > /proc/sys/kernel/threads-max

2. check with ```ipcs -l```

3. in /etc/hosts, the first declaration must be your puvblic IP adresse (no local loopback !)

4. check netstat

### 

### 

### References



### License

free, as libre :)

