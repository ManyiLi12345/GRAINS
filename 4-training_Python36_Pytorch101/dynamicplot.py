# -*- coding: utf-8 -*-
"""
Created on Tue Dec 12 01:26:41 2017

@author: agadipat
"""

from __future__ import absolute_import
import matplotlib.pyplot as plt
#from itertools import izip

class DynamicPlot(object):
    def __init__(self, title, xdata, ydata):
        if len(xdata) == 0:
            return
        plt.ion()
        self.fig = plt.figure()
        self.ax = self.fig.add_subplot(111)
        self.ax.set_title(title, color=u'C0')
        self.ax.set_xlim(xdata[0], xdata[-1])
        self.yline = {}
        for label, data, idx in zip(ydata.keys(), ydata.values(), range(len(ydata))): # In  python 3.x, xrange is replaced by range
            if len(xdata) != len(data):
                print('DynamicPlot::Error: Dimensions of x- and y-data not the same (skipping).') # In python 3.x, the line to be printed should be inside common brackets
                continue
            self.yline[label], = self.ax.plot(xdata, data, u'C{}'.format((idx+1)%9), label=u" ".join(label.split(u'_')))
        self.ax.legend()

    def setxlim(self, xliml, xlimh):
        self.ax.set_xlim(xliml, xlimh)

    def setylim(self, yliml, ylimh):
        self.ax.set_ylim(yliml, ylimh)

    def update_plots(self, ydata):
        for k, v in ydata.items():
            self.yline[k].set_ydata(v)
        self.fig.canvas.draw()
        self.fig.canvas.flush_events()

    def update_plot(self, label, data):
        self.yline[label].set_ydata(data)
        self.fig.canvas.draw()
        self.fig.canvas.flush_events()