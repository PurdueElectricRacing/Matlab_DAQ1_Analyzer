import sys
import re
import datetime
import csv
from pprint import pprint as pp

def s16(value):
	v = int(value, 16)
	return -(v & 0x8000) | (v & 0x7fff)

def imuparsemsg(msg):
	try:
		sensor = int(msg[0:2])
		x = s16('0x' + msg[2:6])
		y = s16('0x' + msg[6:10])
		z = s16('0x' + msg[10:-1])
	except:
		sensor = -1
		x = 'XXXX'
		y = 'XXXX'
		z = 'XXXX'
	return sensor, (x, y, z)

def steerparsemsg(msg):
	data = 'XXXX'
	try:
		a = msg[0:2]
		b = msg[2:4]
		c = msg[4:6]
		d = msg[6:8]
		s = '0x' + d + c + b + a
		data = float(int(s, 16) - 0xaa) / float(0xfff - 0xaa)
	except:
		pass
	return data

if __name__ == '__main__':
	#filename = sys.argv[1]
	filename = '2018_10_12_1_26_8.txt'
	now = datetime.datetime.now()
	now = now.strftime('%d-%m-%Y')
	acc_x = []
	acc_y = []
	acc_z = []
	gyro_x = []
	gyro_y = []
	gyro_z = []
	imu = [acc_x, acc_y, acc_z, gyro_x, gyro_y, gyro_z]
	imuname = ['acc_x', 'acc_y', 'acc_z', 'gyro_x', 'gyro_y', 'gyro_z']
	steer = []
	with open(filename, 'r') as f:
		for line in f:
			try:
				timestamp, CANid, _, msg = line.split(',')
			except:
				pass
			else:
				msg.strip()
				if CANid == '421':
					sensor, data = imuparsemsg(msg)
					try:
						if sensor == 0: #sensor
							imu[0].append((timestamp, str(data[0]))) #x
							imu[1].append((timestamp, str(data[1]))) #y
							imu[2].append((timestamp, str(data[2]))) #z
						elif (sensor == 1): #gyro
							imu[3].append((timestamp, str(data[0]))) #x
							imu[4].append((timestamp, str(data[1]))) #y
							imu[5].append((timestamp, str(data[2]))) #z
					except:
						pass
				if CANid == '422':
					data = steerparsemsg(msg)
					try:
						steer.append((timestamp, str(data)))
					except:
						pass
	for i in range(6):
		with open(now + '_' + imuname[i] + '.csv', 'wb') as f:
			for j in imu[i]:
				f.write(j[0] + ',' + j[1] + '\n')
	with open(now + '_steer' + '.csv', 'wb') as f:
		for i in steer:
			f.write(i[0] + ',' + i[1] + '\n')
