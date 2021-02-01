# -*- coding: utf-8 -*-
"""
ASCII-Art by Pascal Weigmann
licence = "GNU GPL Version 3.0 or later"
created 18.12.2018
contact: p.weigmann@posteo.de
"""

import numpy as np
from PIL import Image
import glob


def importLetters():
    file_list = glob.glob('letters/*.jpg')
    x = np.array([np.array(Image.open(fname)) for fname in file_list])
    letters = ['!','#','%','&','(',')','+','-','0','1','2','3','4','5','6',
                  '7', '8','9','=','"','C','$',':','?','>','I','<','O','.','/',
                  'V','W','X','_']
    letters = {}

    for i in range(len(letters)):
        letters[letters[i]] = x[i]

    return letters
