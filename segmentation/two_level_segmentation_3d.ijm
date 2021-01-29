// Initialize the CLIJ Macro Commands
run("CLIJ2 Macro Extensions", "cl_device=[Tesla V100-PCIE-32GB]");

// Load the Data
open("/archive/MIL/marciano/20201211_CapillaryLooping/cropped/wt/1_CH00_000000.tif");
image1 = getTitle();

// Gamma Correction
//inside_gamma = 0.5;
//Ext.CLIJ_push(image3D);
image2 = "gamma_corrected";
//Ext.CLIJx_gammaCorrection(image1, image2, inside_gamma);
//Ext.CLIJ2_pull("image3Dblurred");

/*
// Gaussian Blur
inside_blur = 3;
Ext.CLIJ2_blur3D(image3Dblurred, image3Dblurred, inside_blur, inside_blur, inside_blur);

// Otsu Threshold
Ext.CLIJ2_thresholdOtsu(image3Dblurred, image3dthresh);

// Iterative Image Dilation
inside_dilation_radius = 4;
for (i = 0; i < inside_dilation_radius; i++) {
	Ext.CLIJ2_dilateSphere(image3dthresh, image3dthresh);
}

// Fill Holes Plane by Plane
Ext.CLIJx_binaryFillHolesSliceBySlice(image3dthresh, image3dthresh);

// Iterative Image Erosion
inside_dilation_radius = 4;
for (i = 0; i < inside_dilation_radius; i++) {
	Ext.CLIJ2_dilateSphere(image3dthresh, image3dthresh);
}

// Gaussian Blur
inside_blur = 1;
Ext.CLIJ2_blur3D(image3dthresh, image3dthresh, inside_blur, inside_blur, inside_blur);


Ext.CLIJ2_pull(image3dthresh);



// Meghan's multilevel segmentation approach.  Gamma -> 3DGaussian -> Otsu -> Dilate -> Fill Holes -> Erode
// 3D Gaussian with 1 voxel size - "Image3Dthresh"
// Raw data - Otsu threshold -> Divide by standard deviation of image.

		
//		print('first dilation')
//	else:
//		image3Ddilated = cle.dilate_sphere(image3Dthresh, image3Ddilated)
//		print('additional dilation')

// No fill holes?

//inside_erode_radius = 6;
//for x in range(inside_erode_radius):
//	if x==0:
//		image3Deroded = cle.create_like(image3Ddilated)
//		image3Deroded = cle.erode_sphere(image3Ddilated, image3Deroded)
//		print('first erosion')
//	else:
//		image3Deroded = cle.erode_sphere(image3Deroded, image3Deroded)
//		print('additional erosion')



// show result
//



//image3Dblurred2 = cle.create_like(image2)
// show result
//cle.imshow(imdata, 'raw_data', False, 30.0, 2837.0)

// Layer Result of gaussian_blur

//image1 = cle.gaussian_blur(imdata, image1, 3.0, 3.0, 3.0)

// Layer Result of subtract_gaussian_background
//image2 = cle.create_like(image1)
//image2 = cle.subtract_gaussian_background(image1, image2, 20.0, 20.0, 20.0)

// Layer Result of gamma_correction

//cle.imshow(image3, 'imdata', False, 30.0, 2837.0)

// Then thresholded the data by eye.  Very challenging otherwise.
//IJ.run("16-bit", "imdata")
//IJ.run("16-bit", "raw_data")
// IJ.run("Merge Channels...", "c1=raw_data c2=imdata create")


