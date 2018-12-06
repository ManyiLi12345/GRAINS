from __future__ import absolute_import
import os
from argparse import ArgumentParser


def get_args():
    parser = ArgumentParser(description=u'grains_pytorch')
    parser.add_argument(u'--box_code_size', type=int, default= 23)
    parser.add_argument(u'--feature_size', type=int, default=250)
    parser.add_argument(u'--feature_size2', type=int, default=500)
    parser.add_argument(u'--relpos_size', type=int, default=28)
    parser.add_argument(u'--hidden_size', type=int, default=750)
    parser.add_argument(u'--hidden_size2', type=int, default=1500)
    

    parser.add_argument(u'--epochs', type=int, default=500)
    parser.add_argument(u'--batch_size', type=int, default= 400)
    parser.add_argument(u'--show_log_every', type=int, default=2)
    parser.add_argument(u'--save_log', action=u'store_true', default=False)
    parser.add_argument(u'--save_log_every', type=int, default=3)
    parser.add_argument(u'--save_snapshot', action=u'store_true', default=False)
    parser.add_argument(u'--save_snapshot_every', type=int, default=5)
    parser.add_argument(u'--save_network_every', type=int, default=100)
    parser.add_argument(u'--no_plot', action=u'store_true', default=False)
    parser.add_argument(u'--lr', type=float, default=0.001)
    parser.add_argument(u'--lr_decay_by', type=float, default=1)
    parser.add_argument(u'--lr_decay_every', type=float, default=1)

    parser.add_argument(u'--no_cuda', action=u'store_true', default=False)
    parser.add_argument(u'--gpu', type=int, default=0)
    parser.add_argument(u'--data_path', default=u'../0-data/4-pydata')
    parser.add_argument(u'--save_path', default=u'../0-data/4-pydata/models')
    parser.add_argument(u'--resume_snapshot', type=unicode, default=u'')
    args = parser.parse_args()
    return args


