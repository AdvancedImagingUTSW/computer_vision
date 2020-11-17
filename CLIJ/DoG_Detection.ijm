// Nuclei Detection
// Author: Kevin Dean
// CH00 - Glomeruli obvious
// CH01 - Glomeruli obvious, but also labels tubules
// CH02 - Weak labeling.

// Open Data
image_name = "1_CH00_110";
// run("Close All");
// open("C:/Users/MicroscopyInnovation/Desktop/Data/"+image_name+".tif");
selectWindow(image_name+".tif");

// Create ROI for Processing on GPU
makeRectangle(822, 558, 1024, 1024);
// makeRectangle(0, 0, 1024, 1024);
run("Duplicate...", "duplicate");

// Select ROI
selectWindow(image_name+"-1.tif");
input = getTitle();
getDimensions(width, height, channels, slices, frames);

//Initialize Variables
blurred = "blurred";
thresholded = "thresholded";
dilated = "dilated";
filled = "filled";
watershedded = "watershedded";

// Init GPU
run("CLIJ2 Macro Extensions", "cl_device=");
Ext.CLIJ2_clear();

// push images to GPU
time = getTime();
print("Pushing Image to GPU");
Ext.CLIJ2_push(input);
print("Pushing one image to the GPU took " + (getTime() - time) + " msec");
print("Imaged Pushed to GPU");
Ext.CLIJ2_reportMemory();

// Difference of Gaussian to Identify Glomeruli
time = getTime();
sigma1 = 50;
sigma2 = 100;
Ext.CLIJ2_differenceOfGaussian3D(input, blurred, sigma1, sigma1, sigma1, sigma2, sigma2, sigma2);
Ext.CLIJ2_release(input);
print("DoG Complete");

// Otsu Threshold
Ext.CLIJ2_thresholdHuang(blurred, thresholded);
// Ext.CLIJ2.release(blurred);
print("Image Thresholded");
Ext.CLIJ2_reportMemory();
Ext.CLIJ2_pull(blurred);

// Dilation & Erosion
// number_of_iterations = 3;
// Ext.CLIJ2_closingBox(thresholded, dilated, number_of_iterations);
// Ext.CLIJ2_release(thresholded);
// print("Imaged Opened");
// Ext.CLIJ2_reportMemory();

// Fill Holes
// Ext.CLIJ2_binaryFillHoles(dilated, filled);
// Ext.CLIJ2_release(dilated);
// print("Holes Filled");
// Ext.CLIJ2_reportMemory();

// Ext.CLIJ2_watershed(filled, watershedded);
// Ext.CLIJ2_release(filled);
// Ext.CLIJ2_reportMemory();

// Get results back from GPU
// Ext.CLIJ2_pull(filled);

// Cleanup GPU 
Ext.CLIJ2_clear();