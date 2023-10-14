import os
import sys
import glob
import time
import serial.tools.list_ports
import serial
import math as m

#----------------------
# get list of all ports
#----------------------
if sys.platform.startswith('win'):
    ports = ['COM%s' % (i + 1) for i in range(256)]
elif sys.platform.startswith('linux') or sys.platform.startswith('cygwin'):
    # this excludes your current terminal "/dev/tty"
    ports = glob.glob('/dev/tty[A-Za-z]*')
elif sys.platform.startswith('darwin'):
    ports = glob.glob('/dev/tty.*')
else:
    raise EnvironmentError('Unsupported platform')

result = []
for port in ports:
    try:
        s = serial.Serial(port)
        s.close()
        result.append(port)
    except (OSError, serial.SerialException):
        pass

if (len(result) == 0):
    print("No devices")
    sys.exit()

#----------------------
# choose port
#----------------------
print("List of devices: {0}".format(result))
print("Enter index of your device: ",end="")
port_number = int(input())

#----------------------
# open communication
#----------------------
ser = serial.Serial(timeout=60)
ser.baudrate = 115200
ser.port = result[port_number]
ser.open()

print("Choose option: \n1) Full mem erase\n2) Write firmwave\n", end="")
what_to_do = int(input())

# send wirst command - we are ready
#ser.write(b"Hello")
#a = ser.read(4)

if (what_to_do == 1):
    send_message = bytes([0x1A])
    ser.write(send_message)
    ans = ser.read(1)
    if (ans == bytes([0xFF])):
        print("Erase finish")
    else:
        print("Erase fail")

elif (what_to_do == 2):
    firmware_file = open("../program/mem.v", "r")
    for line in firmware_file:
        words = line.split()
        #print(words)
        if (words[0][0] == '@'):
            send_message = bytes([0x1C])
            print("new address {0}".format(words[0][1:]))
            send_message += bytes([int(words[0][1:3], base=16)])
            send_message += bytes([int(words[0][3:5], base=16)])
            send_message += bytes([int(words[0][5:7], base=16)])
            send_message += bytes([int(words[0][7:9], base=16)])
            #print(send_message)
            ser.write(send_message)
            ans = ser.read(1)
            if (ans != bytes([0xFF])):
                print("Set address fail")
            time.sleep(0.002)

        else:
            for i in words:
                send_message = bytes([0x1B])
                send_message += bytes([int(i[0:2], base=16)])
                send_message += bytes([int(i[2:4], base=16)])
                send_message += bytes([int(i[4:6], base=16)])
                send_message += bytes([int(i[6:8], base=16)])
                #print(send_message)
                ser.write(send_message)
                ans = ser.read(1)
                if (ans != bytes([0xFF])):
                    print("Set data fail")
                time.sleep(0.002)
                

    sys.exit()


# Protocol of comunication between this app and STM32.
# 