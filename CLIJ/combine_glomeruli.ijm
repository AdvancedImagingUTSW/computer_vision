// Nuclei Detection
// Author: Kevin Dean
// CH00 - Glomeruli obvious
// CH01 - Glomeruli obvious, but also labels tubules
// CH02 - Weak labeling.

run("Close All");
for (channel_idx=0; channel_idx<3; channel_idx++){
	
	// Open Data
	image_name = "1_CH0"+channel_idx+"_110";
	open("C:/Users/MicroscopyInnovation/Desktop/Data/"+image_name+".tif");
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
	blurred = "blurred_"+channel_idx;

	// Init GPU
	run("CLIJ2 Macro Extensions", "cl_device=");
	Ext.CLIJ2_clear();
	
	// push images to GPU
	print("Pushing Image to GPU");
	Ext.CLIJ2_push(input);
	print("Imaged Pushed to GPU");
	close(image_name+"-1.tif");
	
	// Difference of Gaussian to Identify Glomeruli
	time = getTime();
	sigma1 = 50;
	sigma2 = 100;
	Ext.CLIJ2_differenceOfGaussian3D(input, blurred, sigma1, sigma1, sigma1, sigma2, sigma2, sigma2);
	Ext.CLIJ2_pull(blurred);
	print("DoG Complete");
}

// Multiply DoG Images
imageCalculator("Multiply create 32-bit stack", "blurred_1","blurred_2");
selectWindow("Result of blurred_1");
input = getTitle();

// Initialize CLIJ2
run("CLIJ2 Macro Extensions", "cl_device=");
Ext.CLIJ2_clear();

// Push images to GPU
print("Pushing Image to GPU");
Ext.CLIJ2_push(input);
print("Imaged Pushed to GPU");
close(input);

// Threshold Image
output = "output";
Ext.CLIJ2_thresholdHuang(input, output);
print("Image Thresholded");
Ext.CLIJ2_pull(output);



// Combine vertically
// run("Combine...", "stack1=blurred_0 stack2=blurred_1 combine");

// Combine horizontally
run("Combine...", "stack1=blurred_0-1 stack2=blurred_0-2");