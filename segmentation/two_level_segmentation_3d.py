import pyclesperanto_prototype as cle
from ij import IJ

IJ.run("Close All");

# Meghan's multilevel segmentation approach.  Gamma -> 3DGaussian -> Otsu -> Dilate -> Fill Holes -> Erode
# 3D Gaussian with 1 voxel size - "Image3Dthresh"

# Raw data - Otsu threshold -> Divide by standard deviation of image.

image3D = cle.imread('/archive/MIL/marciano/20201211_CapillaryLooping/cropped/wt/1_CH00_000000.tif')
cle.imshow(image3D, 'raw data', True);

# Gamma Correction
inside_gamma = 0.5
image3Dblurred1 = cle.create_like(image3D)
image3Dblurred1 = cle.gamma_correction(image3D, image3Dblurred1, inside_gamma)

# Otsu Threshold
image3Dthresh = cle.create_like(image3Dblurred1)
image3Dthresh = cle.threshold_otsu(image3Dblurred1, image3Dthresh)

# Dilation, Fill Holes, Erosion
# Dilation Occurs 4x.
image3Ddilated1 = cle.create_like(image3Dthresh)
image3Ddilated1 = cle.dilate_sphere(image3Dthresh, image3Ddilated1)

image3Ddilated2 = cle.create_like(image3Ddilated1)
image3Ddilated2 = cle.dilate_sphere(image3Ddilated1, image3Ddilated2)

image3Ddilated3 = cle.create_like(image3Ddilated2)
image3Ddilated3 = cle.dilate_sphere(image3Ddilated2, image3Ddilated3)

image3Ddilated4 = cle.create_like(image3Ddilated3)
image3Ddilated4 = cle.dilate_sphere(image3Ddilated3, image3Ddilated4)

cle.imshow(image3Ddilated4, 'processed image', False)
		
#		print('first dilation')
#	else:
#		image3Ddilated = cle.dilate_sphere(image3Dthresh, image3Ddilated)
#		print('additional dilation')

# No fill holes?

#inside_erode_radius = 6;
#for x in range(inside_erode_radius):
#	if x==0:
#		image3Deroded = cle.create_like(image3Ddilated)
#		image3Deroded = cle.erode_sphere(image3Ddilated, image3Deroded)
#		print('first erosion')
#	else:
#		image3Deroded = cle.erode_sphere(image3Deroded, image3Deroded)
#		print('additional erosion')



# show result
#



#image3Dblurred2 = cle.create_like(image2)
# show result
#cle.imshow(imdata, 'raw_data', False, 30.0, 2837.0)

# Layer Result of gaussian_blur

#image1 = cle.gaussian_blur(imdata, image1, 3.0, 3.0, 3.0)

# Layer Result of subtract_gaussian_background
#image2 = cle.create_like(image1)
#image2 = cle.subtract_gaussian_background(image1, image2, 20.0, 20.0, 20.0)

# Layer Result of gamma_correction

#cle.imshow(image3, 'imdata', False, 30.0, 2837.0)

# Then thresholded the data by eye.  Very challenging otherwise.
#IJ.run("16-bit", "imdata")
#IJ.run("16-bit", "raw_data")
# IJ.run("Merge Channels...", "c1=raw_data c2=imdata create")


