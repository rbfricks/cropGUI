# -*- coding: utf-8 -*-
"""
Created on Tue Jun  9 18:06:04 2020

@author: Spudaluffles
"""

import sys, os, time

import cv2
import numpy as np
import pydicom as pyd
import pandas as pd

from IPython import get_ipython

def clearConsole():
    try:
        # get_ipython().magic('clear')
        # get_ipython().magic('reset -f')
        get_ipython().magic('cls')
    except:
        pass
    
def interpretPath(basePath, path):
    bits = path.split('/')
    outPath = basePath
    for b in bits:
        outPath = os.path.join(outPath,b)
                      
    return outPath

basePath = os.getcwd()
covidList = pd.read_csv('CV19_index.csv', keep_default_na=False,na_values=[], index_col=0)
n_images = len(covidList)

print('For each image, the image will pop up in a separate window for ROI selection. After the ROI has been selected, ' + 
      'the DICOM header will be shown here in the console and then the console will prompt you with questions about the image.')

input('For each image, answer questions by typing a number choice and pressing enter. ' +
      'For ROI, select the ROI as many times as you like and hit enter on the final one to save the last ROI. ' +
      f'DO NOT HIT THE CLOSE BUTTON ON THE ROI WINDOW. {n_images:d} images identified in the list, press \'Enter\' to begin.')



imSize = (800, 800)

i = 0
while(i<3):
    thisEntry = covidList.iloc[i]

    path = interpretPath(basePath, thisEntry['Image Path'])
    print(path)

    imd2 = pyd.filereader.dcmread(path)
    originalImSize = imd2.pixel_array.shape
    
    ### Load and preprocess the image    
    if('Beheshti' in thisEntry['Center']):
        # print('BEHESHTI CASE')
        dcmf = pyd.filereader.dcmread(thisEntry['Image Path'])
        imOut = cv2.resize(dcmf.pixel_array, imSize)
        imOut = np.uint8(np.round(np.float32(imOut) * (255/4095)))
                    
    elif('Busto' in thisEntry['Center']):
        # print('BUSTO CASE')
        dcmf = pyd.filereader.dcmread(thisEntry['Image Path'])
        imOut = cv2.resize(dcmf.pixel_array, imSize)
        imOut = np.clip(imOut, 8319, 26000)
        imOut = np.uint8(np.round(np.float32(imOut-8319) * (255/17681)))
                    
    elif('RUN04-20200519-CHEST' in thisEntry['Center']):                    
        # print('RUN04 CASE')
        dcmf = pyd.filereader.dcmread(thisEntry['Image Path'])
        imOut = cv2.resize(dcmf.pixel_array, imSize)
        imOut = np.uint8(np.round(np.float32(imOut) * (255/4095)))
        
    
    clearConsole()
    print('Select the ROI as many times as you like and hit enter to save the last ROI. ')    
    r = cv2.selectROI(path, imOut)
    
    
    ### Display the DICOM Header in console
    clearConsole()
    
    print(imd2)
    # time.sleep(5)
    
    
    # Is it lateral or frontal? Get from text prompts
    while(True):
        front_or_lat = int(input("Is the image frontal (enter 1) or lateral (enter 2): "))
    
        if(front_or_lat==1):
            print('Frontal image identified.')
            break
        elif(front_or_lat==2):
            print('Lateral image identified')
            break
        else:
            print('Invalid selection, try again.')
    
    # Is it an original image or does it have some kind of post-processing enhancement?
    while(True):
        orig_or_enhanced = int(input("Is the image original (enter 1) or some enhanced variant (enter 2)? (Enhancements include Bone Enhancement, Bone Removal, Clearview, etc.): "))
    
        if(orig_or_enhanced==1):
            print('Original image identified.')
            break
        elif(orig_or_enhanced==2):
            print('Enhanced image identified')
            break
        else:
            print('Invalid selection, try again.')

    i = i + 1