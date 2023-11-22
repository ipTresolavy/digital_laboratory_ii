import random
from serial import Serial

ser = Serial('/dev/ttys049', 115200)
while True:
    send_array = []
    for i in range(6):
        send_array.append(random.randint(0, 15))
    send_array.append(10)
    print(send_array)

    send = bytes(bytearray(send_array))
    ser.write(send)

class MockSerial:
    def __init__(self, port, baud_rate):
        self.port = port
        self.baud_rate = baud_rate
        self.in_waiting = True  # Simulate always having data waiting

    def readline(self):
        # Simulate reading a line from serial port
        lidar = f'{random.randint(0, 255):02x}'
        ultra = f'{random.randint(0, 255):02x}'
        lidar1 = lidar[0]
        lidar2 = lidar[1]
        ultra1 = ultra[0]
        ultra2 = ultra[1]
        simulated_data = bytes(lidar1 + lidar2 + ultra1 + ultra2 + '\n')
        print(simulated_data)
        return simulated_data

    def close(self):
        pass
