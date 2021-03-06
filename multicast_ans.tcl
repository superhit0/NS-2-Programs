# Create scheduler
#Create an event scheduler wit multicast turned on
set ns [new Simulator -multicast on]
#$ns multicast

#Turn on Tracing
set tf [open output.tr w]
$ns trace-all $tf

# Turn on nam Tracing
set fd [open mcast.nam w]
$ns namtrace-all $fd

# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node] 

# Create links
$ns duplex-link $n0 $n1 1Mb 5ms DropTail
$ns duplex-link $n1 $n2 1Mb 5ms DropTail
$ns duplex-link $n1 $n3 1Mb 5ms DropTail
$ns duplex-link $n1 $n4 1Mb 5ms DropTail

# Use the following to make the orientation right.
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n1 $n3 orient down
$ns duplex-link-op $n1 $n4 orient up 

# Routing protocol: say distance vector
#Protocols: CtrMcast, DM, ST, BST
set mproto DM
set mrthandle [$ns mrtproto $mproto {}]

# Allocate group addresses
set group0 [Node allocaddr]
set group1 [Node allocaddr]


# UDP Transport agent for the traffic source
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0
$udp0 set dst_addr_ $group0
$udp0 set dst_port_ 0
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp0

# Transport agent for the traffic source
set udp1 [new Agent/UDP]
$ns attach-agent $n2 $udp1
$udp1 set dst_addr_ $group1
$udp1 set dst_port_ 0
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp1

# Create receiver
set rcvr1 [new Agent/Null]
$ns attach-agent $n3 $rcvr1
set rcvr2 [new Agent/Null]
$ns attach-agent $n4 $rcvr2

$ns at 0.1 "$n3 join-group $rcvr1 $group0"
$ns at 0.12 "$n4 join-group $rcvr2 $group0"
$ns at 0.5 "$n3 leave-group $rcvr1 $group0"
$ns at 0.6 "$n3 join-group $rcvr1 $group1"

# Schedule events
$ns at 0.05 "$cbr1 start"
$ns at 0.8 "$cbr1 stop"

$ns at 0.05 "$cbr2 start"
$ns at 0.8 "$cbr2 stop"

proc finish {} {
global ns tf
$ns flush-trace
close $tf
exec nam mcast.nam &
exit 0

}
$ns at 1.0 "finish"

# Start the simulator
$ns run 
