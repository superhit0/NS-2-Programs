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
$ns duplex-link $n0 $n1 0.7Mb 10ms DropTail
$ns duplex-link $n1 $n2 0.7Mb 20ms DropTail
$ns duplex-link $n2 $n3 0.7Mb 10ms DropTail
$ns duplex-link $n3 $n4 0.7Mb 20ms DropTail
$ns duplex-link $n4 $n5 0.7Mb 10ms DropTail
$ns duplex-link $n5 $n0 0.7Mb 20ms DropTail

#Set Queue Size of link to 10
$ns queue-limit $n0 $n1 10
$ns queue-limit $n1 $n2 10
$ns queue-limit $n2 $n3 10
$ns queue-limit $n3 $n4 10
$ns queue-limit $n4 $n5 10
$ns queue-limit $n5 $n0 10

#Give node position (for NAM)
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right-down
$ns duplex-link-op $n2 $n3 orient left-down
$ns duplex-link-op $n3 $n4 orient left
$ns duplex-link-op $n4 $n5 orient left-up
$ns duplex-link-op $n5 $n0 orient right-up

#Monitor the queue for link. (for NAM)
$ns duplex-link-op $n0 $n1 queuePos 0.5
$ns duplex-link-op $n1 $n2 queuePos 0.5
$ns duplex-link-op $n2 $n3 queuePos 0.5
$ns duplex-link-op $n3 $n4 queuePos 0.5
$ns duplex-link-op $n4 $n5 queuePos 0.5
$ns duplex-link-op $n5 $n0 queuePos 0.5

#Setup a TCP connection1
set tcp [new Agent/TCP]
$tcp set class_ 2
$ns attach-agent $n1 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink
$tcp set fid_ 3

#Setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

#Setup a TCP connection2
set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
$ns attach-agent $n5 $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $n1 $sink2
$ns connect $tcp2 $sink2
$tcp2 set fid_ 4

#Setup a FTP over TCP connection2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set type_ FTP

#Setup a UDP connection1
set udp1 [new Agent/UDP]
$ns attach-agent $n3 $udp1
set null1 [new Agent/Null]
$ns attach-agent $n2 $null1
$ns connect $udp1 $null1
$udp1 set fid_ 1

#Setup a CBR over UDP connection1
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1000
$cbr1 set rate_ 0.7Mb
$cbr1 set random_ false

if 0 {
#Setup a UDP connection2
set udp2 [new Agent/UDP]
$ns attach-agent $n5 $udp2
set null2 [new Agent/Null]
$ns attach-agent $n1 $null2
$ns connect $udp2 $null2
$udp2 set fid_ 2

#Setup a CBR over UDP connection2
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set type_ CBR
$cbr2 set packet_size_ 1000
$cbr2 set rate_ 0.7Mb
$cbr2 set random_ false
}

#Schedule events for the CBR and FTP agents
$ns at 0.1 "$cbr1 start"
$ns at 0.5 "$ftp start"
#$ns at 1.0 "$cbr2 start"
$ns at 1.0 "$ftp2 start"
$ns at 4.0 "$cbr1 stop"
$ns at 4.3 "$ftp stop"
$ns at 4.5 "$ftp2 stop"
#$ns at 4.5 "$cbr2 stop"

#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"

#Print CBR packet size and interval
puts "CBR packet size = [$cbr1 set packet_size_]"
puts "CBR interval = [$cbr1 set interval_]"

#Run the simulation
$ns run
