#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 4 Red
$ns color 3 Green

#Open the NAM trace file
set nf [open out.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns flush-trace
        #Close the NAM trace file
        close $nf
        #Execute NAM on the trace file
        exec nam out.nam &
        exit 0
}

#Create 6 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

#Create links between the nodes
$ns duplex-link $n0 $n1 7Mb 10ms DropTail
$ns duplex-link $n1 $n2 7Mb 10ms DropTail
$ns duplex-link $n2 $n3 7Mb 10ms DropTail
$ns duplex-link $n3 $n4 7Mb 10ms DropTail
$ns duplex-link $n4 $n5 7Mb 10ms DropTail
$ns duplex-link $n5 $n0 7Mb 10ms DropTail
$ns duplex-link $n0 $n3 7Mb 10ms DropTail

#Set Queue Size of link to 10
$ns queue-limit $n0 $n1 10
$ns queue-limit $n1 $n2 10
$ns queue-limit $n2 $n3 10
$ns queue-limit $n3 $n4 10
$ns queue-limit $n4 $n5 10
$ns queue-limit $n5 $n0 10
$ns queue-limit $n0 $n3 10

#Give node position (for NAM)
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right-down
$ns duplex-link-op $n2 $n3 orient left-down
$ns duplex-link-op $n3 $n4 orient left
$ns duplex-link-op $n4 $n5 orient left-up
$ns duplex-link-op $n5 $n0 orient right-up
$ns duplex-link-op $n0 $n3 orient right-down

#Monitor the queue for link. (for NAM)
$ns duplex-link-op $n0 $n1 queuePos 0.5
$ns duplex-link-op $n1 $n2 queuePos 0.5
$ns duplex-link-op $n2 $n3 queuePos 0.5
$ns duplex-link-op $n3 $n4 queuePos 0.5
$ns duplex-link-op $n4 $n5 queuePos 0.5
$ns duplex-link-op $n5 $n0 queuePos 0.5
$ns duplex-link-op $n0 $n3 queuePos 0.5

#------------ Routing Protocol ---------------#
$ns rtproto DV

#Setup a UDP connection1
set udp1 [new Agent/UDP]
$ns attach-agent $n0 $udp1
set null1 [new Agent/Null]
$ns attach-agent $n2 $null1
$ns connect $udp1 $null1
$udp1 set fid_ 1

#Setup a CBR over UDP connection1
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1000
$cbr1 set rate_ 0.1Mb
$cbr1 set random_ false

#Schedule events for the CBR and FTP agents
$ns at 0.01 "$cbr1 start"
$ns rtmodel-at 0.4 down $n0 $n1

$ns at 2.0 "finish"
$ns run
