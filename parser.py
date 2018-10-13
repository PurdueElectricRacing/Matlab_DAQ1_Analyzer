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
		data = s16('0x' + msg[2:6])
	except:
		sensor = 'XX'
		data = 'XXXX'
	return sensor, data

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
	filename = sys.argv[1]
	#filename = '2018_10_13_0_15_17.txt'
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
						imu[sensor].append((timestamp, str(data)))
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
