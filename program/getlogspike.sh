#!/usr/bin/expect -f
log_file -noappend spike.log
set timeout 2
spawn spike -d pk main.o
expect "(spike)"
send "until pc 0 0x000100dc\r\n"

while {True} {
expect {
    "(spike)*" { send "reg 0\r\n"}
    eof {exit 0}
    timeout {exit 0}
}
}

#for {set i 0} {$i <= 10} {incr i} {
#    expect "(spike)" 
#    send "reg 0\r\n"
#    expect "*"
#    expect "*"
#    expect "*"
#    expect "*"
#    expect "*"
#    expect "*"
#    expect "*"
#    expect "*"
#}

#expect "(spike)"
#send "q\r\n"
#expect eof