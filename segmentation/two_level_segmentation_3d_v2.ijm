run("CLIJ2 Macro Extensions", "cl_device=[Tesla V100-PCIE-32GB]");

// Clear Workspace
close("*");

// Load the Data
data_path = "/archive/MIL/marciano/20201211_CapillaryLooping/cropped/wt/1_CH00_000000.tif";
open(data_path);
input = getTitle();
print("Processing Image: "+input);

// Gamma Correction
selectWindow(input);
inside_gamma = 0.5;
run("Gamma...", "value=0.50 stack");

// Gaussian Blur
inside_blur = 3;
Ext.CLIJ2_push(input);
close(input);
Ext.CLIJ2_blur3D(input, blurred, inside_blur, inside_blur, inside_blur);
print("Gaussian Blur Complete");

// Otsu Threshold
Ext.CLIJ2_thresholdOtsu(blurred, blur_threshed);
print("Image Otsu Thresholded");

// 4x Iterative Image Dilation
Ext.CLIJ2_dilateSphere(blur_threshed, temp1);
Ext.CLIJ2_dilateSphere(temp1, temp2);
Ext.CLIJ2_dilateSphere(temp2, temp3);
Ext.CLIJ2_dilateSphere(temp3, temp4);
print("Image Dilation Complete");

// Fill Holes Plane by Plane
//Ext.CLIJx_binaryFillHolesSliceBySlice(temp4, temp5);
//print("Holes Filled");

// Fill Holes in 3D
Ext.CLIJ2_binaryFillHoles(temp4, temp5);

// 6x Iterative Erosion
Ext.CLIJ2_dilateSphere(temp5, temp6);
Ext.CLIJ2_dilateSphere(temp6, temp7);
Ext.CLIJ2_dilateSphere(temp7, temp8);
Ext.CLIJ2_dilateSphere(temp8, temp9);
Ext.CLIJ2_dilateSphere(temp9, temp10);
Ext.CLIJ2_dilateSphere(temp10, temp11);
print("Image Erosion Complete");

// Gaussian Blur
inside_blur = 1;
temp12="image3Dthresh";
Ext.CLIJ2_blur3D(temp11, temp12, inside_blur, inside_blur, inside_blur);
print("Final Gaussian Blur Complete");

// Pull Image
Ext.CLIJ2_pull(temp12);
print("Image Pulled");

// Clear GPU Memory
Ext.CLIJ2_clear();

