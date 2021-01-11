import napari
from tifffile import imread

import numpy as np

run_index = 7

X_val = np.load('/archive/MIL/karbasi/stardist/runs/'+str(run_index)+'/X_val.npy')
Y_val = np.load('/archive/MIL/karbasi/stardist/runs/'+str(run_index)+'/Y_val.npy')
Y_val_pred = np.load('/archive/MIL/karbasi/stardist/runs/'+str(run_index)+'/Y_val_pred.npy')

X_val = np.amax(X_val, axis=2)
Y_val = np.amax(Y_val, axis=2)
Y_val_pred = np.amax(Y_val_pred, axis=2)

with napari.gui_qt():
	viewer = napari.Viewer()
	viewer.add_image(X_val, name='X_val')
	viewer.add_image(Y_val, name='Y_val')
	viewer.add_image(Y_val_pred, name='Y_val_pred')

# first digit in transform changes width?
