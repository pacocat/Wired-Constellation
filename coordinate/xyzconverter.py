# coding:utf-8
#!/usr/bin/python
#import math
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d import Axes3D

DEG_TO_RAD = np.pi/180


# 生データを取得
raw_data = []
file = open('orion_raw_data.txt', 'r')
for line in file:
	if line[0] != '#':
		raw_data.append(line.split('\t'))
file.close()

def ra_to_degree (ra):
	(hh, mm, ss) = ra.split(':')
	deg = int(hh) * 360.0/24 + int(mm) * 360.0/(24*60) + float(ss) * 360.0/(24*60*60)
	return deg

def dec_to_degree (dec):
	(dd, mm, ss) = dec.split(':')
	if dd[0] == '-':
		deg = int(dd) - int(mm)/60.0 - float(ss)/3600.0
	else:
		deg = int(dd) + int(mm)/60.0 + float(ss)/3600.0
	return deg

def deg_to_xyz (alpha, delta, distance):
	x = np.cos(delta*DEG_TO_RAD) * np.cos(alpha*DEG_TO_RAD) * distance
	y = np.cos(delta*DEG_TO_RAD) * np.sin(alpha*DEG_TO_RAD) * distance
	z = np.sin(delta*DEG_TO_RAD) * distance
	return x, y, z

def plot_stars (x, y, z, r):
	fig = plt.figure()
	ax = fig.add_subplot(111, projection='3d')
	ax.scatter(x, y, z, c='r', marker='o', s=r)
	ax.set_xlabel('x')
	ax.set_ylabel('y')
	ax.set_zlabel('z')
	for i in range(len(raw_data)):
		name = raw_data[i][0]
		#ax.text(x[i], y[i], z[i], name)
	plt.show()

# 座標を変換
x_line = []
y_line = []
z_line = []
r_line = []
for i in range(len(raw_data)):
	ra = raw_data[i][6]
	dec = raw_data[i][7]
	alpha = ra_to_degree(ra)
	delta = dec_to_degree(dec)
	distance = float(raw_data[i][10])
	name = raw_data[i][0]
	abs_mag = float(raw_data[i][9])
	flux = pow(10.0, -0.4*abs_mag)
	radius = np.sqrt(flux)
	(x, y, z) = deg_to_xyz(alpha, delta, distance)
	x_line.append(x)
	y_line.append(y)
	z_line.append(z)
	r_line.append(radius)
	print '%-10s %8.3f %8.3f %8.3f %6.1f %7.3f %8.3f %8.3f' % (name, x, y, z, distance, abs_mag, flux, radius)

x = np.array(x_line)
y = np.array(y_line)
z = np.array(z_line)
r = np.array(r_line)

plot_stars(x,y,z,r)



