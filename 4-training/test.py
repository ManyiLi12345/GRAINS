from __future__ import absolute_import
import torch
from torch import nn
from torch.autograd import Variable
import grainsmodel_vae
import scipy.io as sio
import numpy
import util

config = util.get_args()

#encoder = torch.load(u'./models/vae_encoder_model.pkl')
decoder = torch.load(config.save_path + u'/vae_decoder_model.pkl')

boxes_list=[]
rplist_list = []
kids_list=[]
rootcode = []

for n_scenes in xrange(10000): # how many scenes to be generated
  for i in xrange(1):
    test = Variable(torch.randn(1, config.feature_size2)).cuda()
    boxes, rplist, labellist = grainsmodel_vae.decode_structure(decoder, test)
    
    for j in xrange(len(boxes)):
      boxes[j] = boxes[j].data.cpu().numpy()
    for k in xrange(len(rplist)):
      rplist[k] = rplist[k].data.cpu().numpy()
    
    rootcode.append(test.data.cpu().numpy())
    boxes_list.append(boxes)
    rplist_list.append(rplist)
    kids_list.append(labellist)
	
sio.savemat(config.data_path + u'/generated_scenes.mat',{u'boxes':boxes_list, u'rplist':rplist_list, u'kids':kids_list, u'rootcode':rootcode})
