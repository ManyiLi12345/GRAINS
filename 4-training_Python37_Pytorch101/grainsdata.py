# -*- coding: utf-8 -*-
"""
Created on Mon Dec 25 01:33:09 2017

@author: agadipat
"""

from __future__ import absolute_import
import torch
from torch.utils import data
from scipy.io import loadmat
from enum import Enum

class Tree(object):
    
    class NodeType(Enum):
        BOX = 0 # Box node
        SUPP = 1 # Support Node
        COOC = 2 # Co-occurrence Node
        SRND = 3 # Surround Node
        ROOT5 = 4 # Root Node
        WALL = 5 # Wall Node
        
    class Node(object):
        def __init__(self, box = None, left = None, center = None, relpos_center = None, right = None, relpos_right = None, root4 = None, relpos3 = None, root5 = None,  relpos4 = None, node_type = None): #, 
            
            self.box = box # box feature vector for a leaf node
            self.left = left        # left child 
            self.center = center    # center child
            self.relpos_center = relpos_center 
            self.right = right      # right child
            self.relpos_right = relpos_right
            self.root4 = root4 # 4th child of root node
            self.relpos3 = relpos3
            self.root5 = root5 # 5th child of root node
            self.relpos4 = relpos4
            self.node_type = node_type
            self.label = torch.LongTensor([self.node_type.value])
            
        def is_leaf(self):
            return self.node_type == Tree.NodeType.BOX and self.box is not None
        
        def is_supp(self):
            return self.node_type == Tree.NodeType.SUPP
        
        def is_cooc(self):
            return self.node_type == Tree.NodeType.COOC
        
        def is_srnd(self):
            return self.node_type == Tree.NodeType.SRND
        
        def is_root5(self):
            return self.node_type == Tree.NodeType.ROOT5
        
        def is_wall(self):
            return self.node_type == Tree.NodeType.WALL
        
    def __init__(self, boxes, ops, relposes):
        box_list = [b for b in torch.split(boxes, 1, 0)]
        box_list.reverse()
        relpos_list = [r for r in torch.split(relposes, 1, 0)]
        relpos_list.reverse()
        
        queue =[]
        
        for id in range(ops.size()[1]):            
            if ops[0,id] == Tree.NodeType.BOX.value:
                box=box_list.pop()
                queue.append(Tree.Node(box, node_type=Tree.NodeType.BOX)) 
            elif ops[0,id] == Tree.NodeType.SUPP.value:
                right_child = queue.pop()
                left_child = queue.pop()
                relpos2 = relpos_list.pop()
                queue.append(Tree.Node(left=left_child, right=right_child, relpos_right=relpos2, node_type=Tree.NodeType.SUPP))                
            elif ops[0,id] == Tree.NodeType.COOC.value:
                right_child = queue.pop()
                left_child = queue.pop()
                relpos2 = relpos_list.pop()
                queue.append(Tree.Node(left=left_child, right=right_child, relpos_right=relpos2, node_type=Tree.NodeType.COOC))               
            elif ops[0,id] == Tree.NodeType.SRND.value:
                right_child = queue.pop()
                relpos3 = relpos_list.pop()
                center_child = queue.pop()
                relpos2 = relpos_list.pop()
                left_child = queue.pop()
                queue.append(Tree.Node(left=left_child, center = center_child, relpos_center = relpos2, right=right_child, relpos_right=relpos3, node_type=Tree.NodeType.SRND))  
            elif ops[0,id] == Tree.NodeType.ROOT5.value:
                root5 = queue.pop()
                relpos4 = relpos_list.pop()
                root4 = queue.pop()
                relpos3 = relpos_list.pop()
                root3 = queue.pop()
                relpos_root2 = relpos_list.pop()
                root2 = queue.pop()
                root1 = queue.pop()
                relpos_root1 = relpos_list.pop()
                queue.append(Tree.Node(left=root1, center = root2, relpos_center = relpos_root1, right=root3, relpos_right=relpos_root2, root4 =root4, relpos3=relpos3, root5=root5, relpos4 = relpos4, node_type=Tree.NodeType.ROOT5))
            elif ops[0,id] == Tree.NodeType.WALL.value:
                right_child = queue.pop()
                left_child = queue.pop()
                relpos2 = relpos_list.pop()
                queue.append(Tree.Node(left=left_child, right=right_child, relpos_right=relpos2, node_type=Tree.NodeType.WALL))
                
        assert len(queue) == 1 # raise Exception if lenght of queue is not equal to 1
        self.root = queue[0]
        
class GRAINSDataset(data.Dataset):
    
    
    def __init__(self, dir, transform = None):
        self.directory = dir
		
		# load the training data
        box_data = torch.from_numpy(loadmat(self.directory+u'/boxes.mat')[u'boxes']).float()
        op_data = torch.from_numpy(loadmat(self.directory+u'/ops.mat')[u'ops']).int()
        relpos_data = torch.from_numpy(loadmat(self.directory+u'/relpos.mat')[u'relposes']).float()
        
        num_examples = op_data.size()[1]
        box_data = torch.chunk(box_data, num_examples, 1)
        op_data = torch.chunk(op_data, num_examples, 1)
        relpos_data = torch.chunk(relpos_data, num_examples, 1)
        
        self.transform = transform
        self.trees = []
        for i in range(len(op_data)) :
			# organize the hierarchical structure
            boxes = torch.t(box_data[i])
            ops = torch.t(op_data[i])
            relposes = torch.t(relpos_data[i])
            tree = Tree(boxes, ops, relposes)
            self.trees.append(tree)
            
        print("tree num:", len(self.trees))
        
    def __getitem__(self, index):
        tree = self.trees[index]
        return tree

    def __len__(self):
        return len(self.trees)
    
    
            
