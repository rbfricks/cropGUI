# -*- coding: utf-8 -*-
"""
Created on Tue Jun  9 14:10:59 2020

@author: Spudaluffles
"""

import sys, os

import cv2
import numpy as np
import pydicom as pyd

# from PyQt5.QtWidgets import QApplication
# from PyQt5.QtWidgets import QLabel
# from PyQt5.QtWidgets import QWidget

import sys
from PyQt5 import QtCore, QtWidgets, QtGui
from PyQt5.QtWidgets import QMainWindow, QLabel, QGridLayout, QWidget, QPlainTextEdit
from PyQt5.QtCore import QSize 

# im = cv2.imread('test.png')
imSize = (800, 800)

imd2 = pyd.filereader.dcmread('2.dcm')
originalImSize = imd2.pixel_array.shape

imOut = cv2.resize(imd2.pixel_array, imSize)
imOut = np.clip(imOut, 8319, 26000)
imOut = np.uint8(np.round(np.float32(imOut-8319) * (255/17681)))
imOut = np.stack((imOut, imOut, imOut), axis=2)

# r = cv2.selectROI(imOut)


class cdgWindow(QMainWindow):
    def __init__(self):
        QMainWindow.__init__(self)
 
        self.setMinimumSize(QSize(900, 600))    
        self.setWindowTitle("Crop DICOM GUI") 
        
        centralWidget = QWidget(self)          
        self.setCentralWidget(centralWidget)   
 
        gridLayout = QGridLayout(self)     
        centralWidget.setLayout(gridLayout)  
 
        title = QLabel("DICOM Header", self) 
        title.move(5,5)
        title.resize(100,100)
        # title.setAlignment(QtCore.Qt.AlignCenter)
        # gridLayout.addWidget(title, 100, 100)
        
        menu = self.menuBar().addMenu('File')
        action = menu.addAction('Quit')
        action.triggered.connect(QtWidgets.QApplication.quit)
        
        b = QPlainTextEdit(self)
        b.setReadOnly(True) 
        b.insertPlainText(str(imd2))
        b.move(30,50)
        b.resize(800,400)
        # b.verticalScrollBar().setSliderPosition(0)
        b.moveCursor(QtGui.QTextCursor.Start)
 
if __name__ == "__main__":
    def run_app():
        app = QtWidgets.QApplication(sys.argv)
        mainWin = cdgWindow()
        mainWin.show()
        app.exec_()
        # sys.exit(app.exec_())

    run_app()
    

