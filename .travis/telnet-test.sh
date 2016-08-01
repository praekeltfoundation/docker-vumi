#!/usr/bin/expect -f

set timeout 20

spawn telnet localhost 9010

expect "Enter text to echo:"
send "hallo world\r"
expect "hallo world"
sleep 2
