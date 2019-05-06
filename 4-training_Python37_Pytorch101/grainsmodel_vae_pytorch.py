# -*- coding: utf-8 -*-
"""
Created on Sat Dec 23 23:24:32 2017

@author: agadipat
"""

from __future__ import division
from __future__ import absolute_import
import math
import torch
from torch import nn
from torch.autograd import Variable
from time import time
#from itertools import izip

#########################################################################################
## Encoder
#########################################################################################

class Sampler(nn.Module):

    def __init__(self, feature_size, hidden_size):
        super(Sampler, self).__init__()
        self.mlp1 = nn.Linear(feature_size, hidden_size)
        self.mlp2mu = nn.Linear(hidden_size, feature_size)
        self.mlp2var = nn.Linear(hidden_size, feature_size)
        self.tanh = nn.Tanh()
        
    def forward(self, input):
        encode = self.tanh(self.mlp1(input))
        mu = self.mlp2mu(encode)
        logvar = self.mlp2var(encode)
        std = logvar.mul(0.5).exp_()
        eps = Variable(torch.FloatTensor(std.size()).normal_().cuda())
        KLD_element = mu.pow(2).add_(logvar.exp()).mul_(-1).add_(1).add_(logvar)
        return torch.cat([eps.mul(std).add_(mu), KLD_element], 1)

class BoxEncoder(nn.Module): # Box Encoder

    def __init__(self, input_size,feature_size): 
        super(BoxEncoder, self).__init__()
        self.encoder = nn.Linear(input_size, feature_size)
        self.tanh = nn.Tanh()

    def forward(self, box_input):
        box_vector = self.encoder(box_input)
        box_vector = self.tanh(box_vector)
        return box_vector
    
class SuppEncoder(nn.Module): # Support Encoder

    def __init__(self, feature_size, relpos_size, hidden_size):
        super(SuppEncoder, self).__init__()
        self.left = nn.Linear(feature_size, hidden_size)
        self.right = nn.Linear(feature_size, hidden_size, bias=False)
        self.rightpos = nn.Linear(relpos_size, hidden_size, bias=False)
        self.second = nn.Linear(hidden_size, feature_size)
        self.tanh = nn.Tanh()

    def forward(self, left_input, right_input, relpos_right):
        output = self.left(left_input)
        output += self.right(right_input)
        output += self.rightpos(relpos_right)
        output = self.tanh(output)
        output = self.second(output) 
        output = self.tanh(output)
        return output
    
class CoocEncoder(nn.Module): # Co-occurrence Encoder

    def __init__(self, feature_size,  relpos_size, hidden_size):
        super(CoocEncoder, self).__init__()
        self.left = nn.Linear(feature_size, hidden_size)
        self.right = nn.Linear(feature_size, hidden_size, bias=False)
        self.rightpos = nn.Linear(relpos_size, hidden_size, bias=False)
        self.second = nn.Linear(hidden_size, feature_size)
        self.tanh = nn.Tanh()

    def forward(self, left_input, right_input, relpos_right):
        output = self.left(left_input)
        output += self.right(right_input)
        output += self.rightpos(relpos_right)
        output = self.tanh(output)
        output = self.second(output)
        output = self.tanh(output)
        return output

class SrndEncoder(nn.Module): # SURROUND Encoder

    def __init__(self, feature_size, relpos_size, hidden_size):
        super(SrndEncoder, self).__init__()
        self.left = nn.Linear(feature_size, hidden_size) 
        self.right = nn.Linear(feature_size, hidden_size, bias=False) 
        self.rightpos = nn.Linear(relpos_size, hidden_size, bias=False)
        self.center = nn.Linear(feature_size, hidden_size, bias=False) 
        self.centerpos = nn.Linear(relpos_size, hidden_size, bias=False)
        self.second = nn.Linear(hidden_size, feature_size)
        self.tanh = nn.Tanh()

    def forward(self, left_input, center_input, relpos_center, right_input, relpos_right):
        output = self.left(left_input)
        output += self.center(center_input)
        output += self.centerpos(relpos_center)
        output += self.right(right_input)
        output += self.rightpos(relpos_right)
        output = self.tanh(output)
        output = self.second(output)
        output = self.tanh(output)
        return output

    
class R5Encoder(nn.Module):    # Root Encoder class for merging all the 4 walls and the floor
    def __init__(self, feature_size, feature_size2, relpos_size,hidden_size):
        super(R5Encoder, self).__init__()
        self.rc1 = nn.Linear(feature_size, hidden_size) 
        self.rc2 = nn.Linear(feature_size, hidden_size, bias=False) 
        self.rc3 = nn.Linear(feature_size, hidden_size, bias=False) 
        self.rc4 = nn.Linear(feature_size, hidden_size, bias=False) 
        self.rc5 = nn.Linear(feature_size, hidden_size, bias=False) 
        self.relpos_12 = nn.Linear(relpos_size, hidden_size, bias=False)
        self.relpos_13 = nn.Linear(relpos_size, hidden_size, bias=False) 
        self.relpos_14 = nn.Linear(relpos_size, hidden_size, bias=False) 
        self.relpos_15 = nn.Linear(relpos_size, hidden_size, bias=False)
        self.second = nn.Linear(hidden_size, feature_size2)
        self.tanh = nn.Tanh()        

    def forward(self, rc1, rc2, relpos_12, rc3, relpos_13, rc4, relpos_14, rc5,relpos_15):
        output = self.rc1(rc1)
        output += self.rc2(rc2)
        output += self.relpos_12(relpos_12)
        
        output += self.rc3(rc3)
        output += self.relpos_13(relpos_13)
        
        output += self.rc4(rc4)
        output += self.relpos_14(relpos_14)
        
        output += self.rc5(rc5)
        output += self.relpos_15(relpos_15)
        output = self.tanh(output)
        output = self.second(output)
        output = self.tanh(output)
        return output
  

class WallEncoder(nn.Module): # Wall Encoder

    def __init__(self, feature_size,  relpos_size, hidden_size):
        super(WallEncoder, self).__init__()
        self.left = nn.Linear(feature_size, hidden_size) 
        self.right = nn.Linear(feature_size, hidden_size, bias=False) 
        self.rightpos = nn.Linear(relpos_size, hidden_size, bias=False)
        self.second = nn.Linear(hidden_size, feature_size)
        self.tanh = nn.Tanh()

    def forward(self, left_input, right_input, relpos_right):
        output = self.left(left_input)
        output += self.right(right_input)
        output += self.rightpos(relpos_right)
        output = self.tanh(output)
        output = self.second(output)
        output = self.tanh(output)
        return output
    

class GRAINSEncoder(nn.Module):

    def __init__(self, config):
        super(GRAINSEncoder, self).__init__()
        self.boxEncoder = BoxEncoder(input_size = config.box_code_size, feature_size = config.feature_size)
        self.suppEncoder = SuppEncoder(feature_size = config.feature_size, relpos_size = config.relpos_size, hidden_size = config.hidden_size)
        self.coocEncoder = CoocEncoder(feature_size = config.feature_size, relpos_size = config.relpos_size, hidden_size = config.hidden_size)
        self.srndEncoder = SrndEncoder(feature_size = config.feature_size, relpos_size = config.relpos_size, hidden_size = config.hidden_size)
        self.r5Encoder = R5Encoder(feature_size = config.feature_size, feature_size2 = config.feature_size2, relpos_size = config.relpos_size, hidden_size = config.hidden_size2)
        self.wallEncoder = WallEncoder(feature_size = config.feature_size, relpos_size = config.relpos_size, hidden_size = config.hidden_size)
        self.sampler = Sampler(feature_size = config.feature_size2, hidden_size = config.hidden_size)

    def leafNode(self, box):
        return self.boxEncoder(box)

    def suppNode(self, left, right,relpos_right):
        return self.suppEncoder(left, right,relpos_right)

    def coocNode(self, left,right,relpos_right):
        return self.coocEncoder(left, right,relpos_right)

    def srndNode(self, left, center, relpos_center, right, relpos_right):
        return self.srndEncoder(left, center,relpos_center, right, relpos_right)
        
    def r5Node(self, rc1,rc2,relpos_12, rc3, relpos_13, rc4, relpos_14, rc5, relpos_15):#,w3,r13,w4,r14):
        return self.r5Encoder(rc1,rc2,relpos_12, rc3, relpos_13, rc4, relpos_14, rc5, relpos_15)#,w3,r13,w4,r14)

    def wallNode(self, left, right, relpos_right):
        return self.wallEncoder(left, right, relpos_right)
    
    def sampleLayer(self, feature):
        return self.sampler(feature)

   
def encode_structure_fold(fold, tree):
    
    def encode_node(node):       
        if node.is_leaf():
            return fold.add(u'leafNode', node.box)
            
        elif node.is_supp():
            left = encode_node(node.left)
            right = encode_node(node.right)
            return fold.add(u'suppNode', left, right, node.relpos_right)
            
        elif node.is_cooc():
            left = encode_node(node.left)
            right = encode_node(node.right)
            return fold.add(u'coocNode', left, right, node.relpos_right)
            
        elif node.is_srnd():
            left = encode_node(node.left)
            center = encode_node(node.center)
            right = encode_node(node.right)
            return fold.add(u'srndNode', left, center, node.relpos_center, right, node.relpos_right) 
        
        elif node.is_root5():
            rc1 = encode_node(node.left)
            rc2 = encode_node(node.center)
            rc3 = encode_node(node.right)
            rc4 = encode_node(node.root4)
            rc5 = encode_node(node.root5)
            return fold.add(u'r5Node',rc1,rc2,node.relpos_center, rc3, node.relpos_right, rc4, node.relpos3, rc5, node.relpos4)#,w3,node.relpos_right,w4,node.relpos_wall4)
    
        elif node.is_wall():
            left = encode_node(node.left)
            right = encode_node(node.right)
            return fold.add(u'wallNode', left, right, node.relpos_right)
        
    encoding = encode_node(tree.root)
    return  fold.add(u'sampleLayer', encoding)

#########################################################################################
## Decoder
#########################################################################################


class NodeClassifier(nn.Module):

    def __init__(self, feature_size, hidden_size):
        super(NodeClassifier, self).__init__()
        self.mlp1 = nn.Linear(feature_size, hidden_size)
        self.tanh = nn.Tanh()
        self.mlp2 = nn.Linear(hidden_size, 5) # there are 5 kinds of encoders , BOX, SUPP, CO-OC, SRND and WALL
        #self.softmax = nn.Softmax()

    def forward(self, input_feature):
        output = self.mlp1(input_feature)
        output = self.tanh(output)
        output = self.mlp2(output)
        #output = self.softmax(output)
        return output

class SampleDecoder(nn.Module):
    u""" Decode a randomly sampled noise into a feature vector """
    def __init__(self, feature_size, hidden_size):
        super(SampleDecoder, self).__init__()
        self.mlp1 = nn.Linear(feature_size, hidden_size)
        self.mlp2 = nn.Linear(hidden_size, feature_size)
        self.tanh = nn.Tanh()
        
    def forward(self, input_feature):
        output = self.tanh(self.mlp1(input_feature))
        output = self.tanh(self.mlp2(output))
        return output


class SuppDecoder(nn.Module):
    u""" Decode an input (parent) feature into a left-child, left rel_pos. right_child and a right rel_pos feature """
    def __init__(self, feature_size,relpos_size, hidden_size):
        super(SuppDecoder, self).__init__()
        self.mlp = nn.Linear(feature_size, hidden_size)
        self.mlp_left = nn.Linear(hidden_size, feature_size)
        self.mlp_right = nn.Linear(hidden_size, feature_size)
        self.mlp_rightpos = nn.Linear(hidden_size, relpos_size)
        self.tanh = nn.Tanh()

    def forward(self, parent_feature):
        vector = self.mlp(parent_feature)
        vector = self.tanh(vector)
        left_code = self.mlp_left(vector) 
        left_code = self.tanh(left_code)
        right_code = self.mlp_right(vector)
        right_code = self.tanh(right_code)
        right_pos = self.mlp_rightpos(vector)
        right_pos = self.tanh(right_pos)
        return left_code, right_code, right_pos

		
class CoocDecoder(nn.Module):
    u""" Decode an input (parent) feature into a left-child, left rel_pos. right_child and a right rel_pos feature """
    def __init__(self, feature_size,relpos_size, hidden_size):
        super(CoocDecoder, self).__init__()
        self.mlp = nn.Linear(feature_size, hidden_size)
        self.mlp_left = nn.Linear(hidden_size, feature_size)
        self.mlp_right = nn.Linear(hidden_size, feature_size)
        self.mlp_rightpos = nn.Linear(hidden_size, relpos_size)
        self.tanh = nn.Tanh()

    def forward(self, parent_feature):
        vector = self.mlp(parent_feature)
        vector = self.tanh(vector)
        left_code = self.mlp_left(vector)
        left_code = self.tanh(left_code)
        right_code = self.mlp_right(vector)
        right_code = self.tanh(right_code)
        right_pos = self.mlp_rightpos(vector)
        right_pos = self.tanh(right_pos)
        return left_code, right_code, right_pos

class SrndDecoder(nn.Module):
    u""" Decode an input (parent) feature into a left-child, left rel_pos. right_child and a right rel_pos feature """
    def __init__(self, feature_size,relpos_size, hidden_size):
        super(SrndDecoder, self).__init__()
        self.mlp = nn.Linear(feature_size, hidden_size)
        self.mlp_left = nn.Linear(hidden_size, feature_size)
        self.mlp_center = nn.Linear(hidden_size, feature_size)
        self.mlp_centerpos = nn.Linear(hidden_size, relpos_size)
        self.mlp_right = nn.Linear(hidden_size, feature_size)
        self.mlp_rightpos = nn.Linear(hidden_size, relpos_size)
        self.tanh = nn.Tanh()

    def forward(self, parent_feature):
        vector = self.mlp(parent_feature)
        vector = self.tanh(vector)
        left_code = self.mlp_left(vector) 
        left_code = self.tanh(left_code)
        center_code = self.mlp_center(vector)
        center_code = self.tanh(center_code)
        center_pos = self.mlp_centerpos(vector)
        center_pos = self.tanh(center_pos)
        right_code = self.mlp_right(vector)
        right_code = self.tanh(right_code)
        right_pos = self.mlp_rightpos(vector)
        right_pos = self.tanh(right_pos)
        return left_code, center_code, center_pos, right_code, right_pos

class R5Decoder(nn.Module):
    u""" Decode an input (parent) feature into a left-child, left rel_pos. right_child and a right rel_pos feature """
    def __init__(self, feature_size, feature_size2, relpos_size, hidden_size):
        super(R5Decoder, self).__init__()
        self.mlp = nn.Linear(feature_size2, hidden_size)
        self.mlp_rc1 = nn.Linear(hidden_size, feature_size)
        self.mlp_rc2 = nn.Linear(hidden_size, feature_size)
        self.mlp_rc3 = nn.Linear(hidden_size, feature_size)
        self.mlp_rc4 = nn.Linear(hidden_size, feature_size)
        self.mlp_rc5 = nn.Linear(hidden_size, feature_size)
        self.mlp_relpos_12 = nn.Linear(hidden_size, relpos_size)
        self.mlp_relpos_13 = nn.Linear(hidden_size, relpos_size)
        self.mlp_relpos_14 = nn.Linear(hidden_size, relpos_size)
        self.mlp_relpos_15 = nn.Linear(hidden_size, relpos_size)
        self.tanh = nn.Tanh()

    def forward(self, parent_feature):
        vector = self.mlp(parent_feature)
        vector = self.tanh(vector)
        rc1 = self.mlp_rc1(vector) 
        rc1 = self.tanh(rc1)
        rc2 = self.mlp_rc2(vector)
        rc2 = self.tanh(rc2)
        relpos_12 = self.mlp_relpos_12(vector)
        relpos_12 = self.tanh(relpos_12)
        
        rc3 = self.mlp_rc3(vector)
        rc3 = self.tanh(rc3)
        relpos_13 = self.mlp_relpos_13(vector)
        relpos_13 = self.tanh(relpos_13)
        
        rc4 = self.mlp_rc4(vector)
        rc4 = self.tanh(rc4)
        relpos_14 = self.mlp_relpos_14(vector)
        relpos_14 = self.tanh(relpos_14)
        
        rc5 = self.mlp_rc5(vector)
        rc5 = self.tanh(rc5)
        relpos_15 = self.mlp_relpos_15(vector)
        relpos_15 = self.tanh(relpos_15)
        
        return rc1,rc2,relpos_12,rc3,relpos_13,rc4,relpos_14,rc5,relpos_15#,w3,r13,w4,r14


class WallDecoder(nn.Module):
    u""" Decode an input (parent) feature into a left-child, left rel_pos. right_child and a right rel_pos feature """
    def __init__(self, feature_size,relpos_size, hidden_size):
        super(WallDecoder, self).__init__()
        self.mlp = nn.Linear(feature_size, hidden_size)
        self.mlp_left = nn.Linear(hidden_size, feature_size)
        self.mlp_right = nn.Linear(hidden_size, feature_size)
        self.mlp_rightpos = nn.Linear(hidden_size, relpos_size)
        self.tanh = nn.Tanh()

    def forward(self, parent_feature):
        vector = self.mlp(parent_feature)
        vector = self.tanh(vector)
        left_code = self.mlp_left(vector) 
        left_code = self.tanh(left_code)
        right_code = self.mlp_right(vector)
        right_code = self.tanh(right_code)
        right_pos = self.mlp_rightpos(vector)
        right_pos = self.tanh(right_pos)
        return left_code, right_code, right_pos



class BoxDecoder(nn.Module):

    def __init__(self, feature_size, box_size):
        super(BoxDecoder, self).__init__()
        self.mlp = nn.Linear(feature_size, box_size)
        self.tanh = nn.Tanh()

    def forward(self, parent_feature):
        vector = self.mlp(parent_feature)
        vector = self.tanh(vector)
        return vector
    
class GRAINSDecoder(nn.Module):
    def __init__(self, config):
        super(GRAINSDecoder, self).__init__()
        self.box_decoder = BoxDecoder(feature_size = config.feature_size, box_size = config.box_code_size)
        self.supp_decoder = SuppDecoder(feature_size = config.feature_size, relpos_size = config.relpos_size, hidden_size = config.hidden_size)
        self.cooc_decoder = CoocDecoder(feature_size = config.feature_size, relpos_size = config.relpos_size, hidden_size = config.hidden_size)
        self.srnd_decoder = SrndDecoder(feature_size = config.feature_size, relpos_size = config.relpos_size, hidden_size = config.hidden_size)
        self.r5_decoder  = R5Decoder(feature_size = config.feature_size, feature_size2 = config.feature_size2, relpos_size = config.relpos_size, hidden_size = config.hidden_size2)
        self.wall_decoder = WallDecoder(feature_size = config.feature_size, relpos_size = config.relpos_size, hidden_size = config.hidden_size)
        self.sample_decoder = SampleDecoder(feature_size = config.feature_size2, hidden_size = config.hidden_size)
        self.node_classifier = NodeClassifier(feature_size = config.feature_size, hidden_size = config.hidden_size)
        self.mseLoss = nn.MSELoss()  
        self.creLoss = nn.CrossEntropyLoss() 
        
    def boxDecoder(self, feature):
        return self.box_decoder(feature)

    def SuppDecoder(self, feature):
        return self.supp_decoder(feature)

    def CoocDecoder(self, feature):
        return self.cooc_decoder(feature)

    def SrndDecoder(self, feature):
        return self.srnd_decoder(feature)
    
    def R5Decoder(self,feature):
        return self.r5_decoder(feature)
    
    def WallDecoder(self,feature):
        return self.wall_decoder(feature)
    
    def sampleDecoder(self, feature):
        return self.sample_decoder(feature)
    
    def nodeClassifier(self, feature):
        return self.node_classifier(feature)

    def boxLossEstimator(self, box_feature, gt_box_feature): #gt_box_feature is the ground truth for the box feature
        return torch.cat([self.mseLoss(b.unsqueeze(0), gt.unsqueeze(0)).mul(0.5).unsqueeze(0) for b, gt in zip(box_feature, gt_box_feature)], 0)
    
    def relposLossEstimator(self, relpos_feature, gt_relpos_feature): #gt_relpos_feature is the ground truth for the relpos feature
        return torch.cat([self.mseLoss(r.unsqueeze(0), gt.unsqueeze(0)).mul(0.5).unsqueeze(0) for r, gt in zip(relpos_feature, gt_relpos_feature)], 0)

    def classifyLossEstimator(self, label_vector, gt_label_vector):
        return torch.cat([self.creLoss(l.unsqueeze(0), gt.unsqueeze(0)).mul(0.5).unsqueeze(0) for l, gt in zip(label_vector, gt_label_vector)], 0)

    def vectorAdder(self, v1, v2):
        return v1.add_(v2)
    
def decode_structure_fold(fold, tree, feature):
    
    def decode_node_box(node, feature):
        
        if node.is_leaf():
            box = fold.add(u'boxDecoder', feature)
            recon_loss = fold.add(u'boxLossEstimator', box, node.box)
            label = fold.add(u'nodeClassifier', feature)
            label_loss = fold.add(u'classifyLossEstimator', label, node.label)
            return fold.add(u'vectorAdder', recon_loss, label_loss)
        
        elif node.is_supp():
            left, right,relpos_right = fold.add(u'SuppDecoder', feature).split(3)
            left_loss = decode_node_box(node.left, left)
            right_loss = decode_node_box(node.right, right)
            right_relpos_loss = fold.add(u'relposLossEstimator', relpos_right, node.relpos_right)
            label = fold.add(u'nodeClassifier', feature)
            label_loss = fold.add(u'classifyLossEstimator', label, node.label)
            right_loss = fold.add(u'vectorAdder', right_loss, right_relpos_loss)
            loss = fold.add(u'vectorAdder', left_loss, right_loss)
            return fold.add(u'vectorAdder', loss, label_loss)
        
        elif node.is_cooc():
            left, right,relpos_right = fold.add(u'CoocDecoder', feature).split(3)
            left_loss = decode_node_box(node.left, left)
            right_loss = decode_node_box(node.right, right)
            right_relpos_loss = fold.add(u'relposLossEstimator', relpos_right, node.relpos_right)
            label = fold.add(u'nodeClassifier', feature)
            label_loss = fold.add(u'classifyLossEstimator', label, node.label)
            right_loss = fold.add(u'vectorAdder', right_loss, right_relpos_loss)
            loss = fold.add(u'vectorAdder', left_loss, right_loss)
            return fold.add(u'vectorAdder', loss, label_loss)
        
        elif node.is_srnd():
            left, center,relpos_center, right,relpos_right = fold.add(u'SrndDecoder', feature).split(5)
            left_loss = decode_node_box(node.left,left)
            center_loss = decode_node_box(node.center, center)
            center_relpos_loss = fold.add(u'relposLossEstimator', relpos_center, node.relpos_center)
            right_loss = decode_node_box(node.right, right)
            right_relpos_loss = fold.add(u'relposLossEstimator', relpos_right, node.relpos_right)
            label = fold.add('nodeClassifier', feature)
            label_loss = fold.add('classifyLossEstimator', label, node.label)
            center_loss = fold.add('vectorAdder', center_loss, center_relpos_loss)
            right_loss = fold.add('vectorAdder', right_loss, right_relpos_loss)
            loss = fold.add('vectorAdder', left_loss, center_loss)
            loss = fold.add('vectorAdder', loss, right_loss)
            return fold.add('vectorAdder', loss, label_loss)      
        
        elif node.is_wall():
            left, right,relpos_right = fold.add(u'WallDecoder', feature).split(3)
            left_loss = decode_node_box(node.left, left)
            right_loss = decode_node_box(node.right, right)
            right_relpos_loss = fold.add(u'relposLossEstimator', relpos_right, node.relpos_right)
            label = fold.add(u'nodeClassifier', feature)
            label_loss = fold.add(u'classifyLossEstimator', label, node.label-1)
            right_loss = fold.add(u'vectorAdder', right_loss, right_relpos_loss)
            loss = fold.add(u'vectorAdder', left_loss, right_loss)
            return fold.add(u'vectorAdder', loss, label_loss)
        
                
    feature = fold.add(u'sampleDecoder', feature) 
    node = tree.root
    rc1,rc2,relpos_12,rc3,relpos_13,rc4,relpos_14,rc5,relpos_15 = fold.add(u'R5Decoder',feature).split(9)
    rc1_loss = decode_node_box(node.left,rc1)
    rc2_loss = decode_node_box(node.center,rc2)
    relpos_12_loss = fold.add(u'relposLossEstimator', relpos_12, node.relpos_center)
    rc2_loss = fold.add('vectorAdder',rc2_loss, relpos_12_loss)
    
    rc3_loss = decode_node_box(node.right,rc3)
    relpos_13_loss = fold.add(u'relposLossEstimator', relpos_13, node.relpos_right)
    rc3_loss = fold.add('vectorAdder',rc3_loss, relpos_13_loss)
    
    rc4_loss = decode_node_box(node.root4, rc4)
    relpos_14_loss = fold.add(u'relposLossEstimator', relpos_14, node.relpos3)
    rc4_loss = fold.add('vectorAdder',rc4_loss, relpos_14_loss)
    
    rc5_loss = decode_node_box(node.root5, rc5)
    relpos_15_loss = fold.add(u'relposLossEstimator', relpos_15, node.relpos4)
    rc5_loss = fold.add('vectorAdder',rc5_loss, relpos_15_loss)
    w12_loss = fold.add('vectorAdder',rc1_loss, rc2_loss)
    w13_loss = fold.add('vectorAdder',w12_loss, rc3_loss)
    w14_loss = fold.add('vectorAdder',w13_loss, rc4_loss)
    w15_loss = fold.add('vectorAdder',w14_loss, rc5_loss)
    return w15_loss

#########################################################################################
## Functions for model testing: Decode a root code into a tree structure of boxes
#########################################################################################
def vrrotvec2mat(rotvector):
    s = math.sin(rotvector[3])
    c = math.cos(rotvector[3])
    t = 1 - c
    x = rotvector[0]
    y = rotvector[1]
    z = rotvector[2]
    m = torch.FloatTensor([[t*x*x+c, t*x*y-s*z, t*x*z+s*y], [t*x*y+s*z, t*y*y+c, t*y*z-s*x], [t*x*z-s*y, t*y*z+s*x, t*z*z+c]]).cuda()
    return m

def decode_structure(model, feature):
    decode = model.sampleDecoder(feature)
    nodecount = 1;
    stack = []
    rplist = []
    boxes = []
    kids = []
    attachs = []
    
    rc1,rc2,relpos_12,rc3,relpos_13,rc4,relpos_14,rc5,relpos_15 = model.R5Decoder(decode)
    stack.append(rc1)
    stack.append(rc2)
    rplist.extend(relpos_12)
    stack.append(rc3)
    rplist.extend(relpos_13)
    stack.append(rc4)
    rplist.extend(relpos_14)
    stack.append(rc5)
    rplist.extend(relpos_15)
    kids.append([4,nodecount+1,nodecount+2,nodecount+3,nodecount+4,nodecount+5])
    nodecount = nodecount+5
    
    while len(stack) > 0:
        f = stack[0]
        stack = stack[1:]
        
        label_prob = model.nodeClassifier(f)
        _, label = torch.max(label_prob, 1)
        label = label.data # classify
        
        if label[0] == 1:
            #print u"support node."
            left, right,relpos_right = model.SuppDecoder(f)
            stack.append(left)
            stack.append(right)
            kids.append([1,nodecount+1,nodecount+2,0,0,0])           
            nodecount = nodecount+2
            rplist.extend(relpos_right)
        if label[0] == 2:
            #print u"group node."
            left, right,relpos_right = model.CoocDecoder(f)
            stack.append(left)
            stack.append(right)
            kids.append([2,nodecount+1,nodecount+2,0,0,0])
            nodecount = nodecount+2
            rplist.extend(relpos_right) 
        if label[0] == 3:
            #print u"surround node."
            left, center,relpos_center, right, relpos_right = model.SrndDecoder(f)
            stack.append(left)
            stack.append(center)
            rplist.extend(relpos_center)
            stack.append(right)
            kids.append([3,nodecount+1,nodecount+2,nodecount+3,0,0])
            nodecount = nodecount+3
            rplist.extend(relpos_right)
        
        if label[0] == 4:
            #print u"wall node."
            rc1,rc2,relpos_12 = model.WallDecoder(f)
            stack.append(rc1)
            stack.append(rc2)
            rplist.extend(relpos_12)
            kids.append([5,nodecount+1,nodecount+2,0,0,0])
            nodecount = nodecount+2            
            
        if label[0] == 0:
            #print u"box node."
            reBox = model.boxDecoder(f)
            bo = reBox.data.cpu().numpy()
            la = bo[0]
            la = la[3:];
            #print u"label:",la.argmax()
            boxes.extend(reBox)
            kids.append([0,0,0,0,0,0])
            
    #print u"Kids are....", kids
    return boxes, rplist, kids