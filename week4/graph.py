from serial import Serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque

serial_port = '/dev/ttys048'  
baud_rate = 115200
max_length = 50  
ser = Serial(serial_port, baud_rate)
lidar_list = deque([0]*max_length, maxlen=max_length)
ultra_list = deque([0]*max_length, maxlen=max_length)
kalman_list = deque([0]*max_length, maxlen=max_length)
fig, ax = plt.subplots()

# Initialize x data for all lines
x_data = list(range(max_length))

def update_graph(frame):
    measurement_list = []
    data = ser.read()
    while data != b'\n' or len(measurement_list) < 6:
        measurement_list.append("0x" + data.hex())
        data = ser.read()
    try:
        lidar = int(measurement_list[0], 0) + int(measurement_list[1], 0)*16
        ultra = int(measurement_list[2], 0) + int(measurement_list[3], 0)*16
        kalman = int(measurement_list[4], 0) + int(measurement_list[5], 0)*16
    except IndexError:
        print(measurement_list)

        lidar = 1000
        ultra = 1000
        kalman = 1000
    lidar_list.append(lidar)
    ultra_list.append(ultra)
    kalman_list.append(kalman)

    # Update both x and y data of each line
    line1.set_data(x_data, list(lidar_list))
    line2.set_data(x_data, list(ultra_list))
    line3.set_data(x_data, list(kalman_list))
    ser.read_all()

    return line1, line2, line3 

line1, = ax.plot([], [], color='green')   # Line for lidar_list
line2, = ax.plot([], [], color='blue')    # Line for ultra_list
line3, = ax.plot([], [], color='magenta') # Line for kalman_list

ax.set_xlim(0, max_length - 1)
ax.set_ylim(0, 1000)  

ani = animation.FuncAnimation(fig, update_graph, interval=1)


plt.show()
