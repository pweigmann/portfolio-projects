# -*- coding: utf-8 -*-
"""
ASCII-Art by Pascal Weigmann
licence = "GNU GPL Version 3.0 or later"
created 18.12.2018
contact: p.weigmann@posteo.de
"""

import numpy as np
import math
import os
from PIL import Image
from import_letters import importLetters

B = importLetters()

# enter name of .jpg file to be transformed
path = "pictures"
image_list = []
# create list of all .jpg files in subdirectory
for entry in os.scandir(path):
    if entry.name.endswith('.jpg'):
        image_list.append(entry.name.split(".")[0])

image = image_list[11]

# read image
im = Image.open('pictures/' + image + '.jpg')
pix = im.load()
width, height = im.size

# get pixel intensities as RGB values in one list
pixel_values = list(im.getdata())

# reshape list to matrix, corresponding to pixel position
px = np.array(pixel_values).reshape((height, width, 3))
cluster_scale_w = 10  # set width of clusters [px/letter]
cluster_scale_h = 10  # set height of clusters [px/letter]
width_cluster = math.floor(width/cluster_scale_w)
height_cluster = math.floor(height/cluster_scale_h)

# TODO: could be used later for smarter choice of symbols
# rearrange letter-matrices to size of one cluster
# letters originally have width of 25px and height of 45px
# letter_scale_w = math.floor(25/cluster_scale_w)
# letter_scale_h = math.floor(45/cluster_scale_h)
# Bs = {}
# for i in B.keys():
#     Bs[i] = np.zeros((cluster_scale_h, cluster_scale_w))
#     for y in range(cluster_scale_w):
#         for x in range(cluster_scale_h):
#             Bs[i][x][y] = B[i][x*letter_scale_h:(x+1)*letter_scale_h,
#                               y*letter_scale_w:(y+1)*letter_scale_w].sum()

# initialize matrix of clusters
cluster_int = np.zeros((height_cluster, width_cluster))
for y in range(width_cluster):
    for x in range(height_cluster):
        # sum up RGB values within each cluster to one single value
        cluster_int[x, y] = px[x*cluster_scale_h:(x+1)*cluster_scale_h,
                            y*cluster_scale_w:(y+1)*cluster_scale_w].sum()

# normalize cluster color values to greyscale
c_int_n = cluster_int/(cluster_scale_w*cluster_scale_h)/3/255
int_min = c_int_n.min()
c_int_n = c_int_n - int_min  # normalize to 0 to 255-min
int_max = c_int_n.max()
c_int_n = 1 - c_int_n/int_max  # normalize to values from 0 to 1 and invert

# initialize matrix with symbols
cluster_sym = np.zeros((height_cluster, width_cluster), dtype='U6')

# input for letters and their "darkness" value
greyscale = np.arange(0, 1, 0.1)
letters = [" ", ",", "i", "l", "7", "t", "b", "Z", "W", "&"]

for y in range(width_cluster):
    for x in range(height_cluster):
        # decide which letter is chosen for each cluster:
        # find index of closest value in "greyscale" and use the
        # corresponding "letters" element
        idx = (np.abs(greyscale - c_int_n[x][y])).argmin()
        cluster_sym[x][y] = letters[idx]

# save symbol-matrix in .txt file
np.savetxt("output/" + image + '_' + str(width_cluster) + '_' +
           str(height_cluster) + '.txt', cluster_sym, "%s", delimiter="")
print("File " + image + '_' + str(width_cluster) + '_' +
      str(height_cluster) + '.txt created.')
