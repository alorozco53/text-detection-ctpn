#! /usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import tensorflow as tf

from lib.fast_rcnn.config import cfg, cfg_from_file
from lib.networks.factory import get_network
from ctpn.demo import ctpn
from pprint import pprint

if __name__ == '__main__':
    sample_img = 'data/demo/sample.jpg'
    cfg_from_file('ctpn/text.yml')

    # restart tensorflow session
    config = tf.ConfigProto(allow_soft_placement=True)
    sess = tf.Session(config=config)

    # load network
    net = get_network("VGGnet_test")

    # load model
    print(('Loading network {:s}... '.format("VGGnet_test")), end=' ')
    saver = tf.train.Saver()

    # load weights
    try:
        ckpt = tf.train.get_checkpoint_state(cfg.TEST.checkpoints_path)
        print('Restoring from {}...'.format(ckpt.model_checkpoint_path), end=' ')
        saver.restore(sess, ckpt.model_checkpoint_path)
        print('done')
    except:
        raise 'Check your pretrained {:s}'.format(ckpt.model_checkpoint_path)

    # run CTPN on sample_image
    box_points = ctpn(sess, net, sample_img, serialize=False)
    pprint(box_points)
