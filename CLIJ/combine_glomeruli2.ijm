// Nuclei Detection
// Author: Kevin Dean
// CH00 - Glomeruli obvious
// CH01 - Glomeruli obvious, but also labels tubules
// CH02 - Weak labeling.

run("Close All");

// Open Data
tile_idx = 214;
for (channel_idx = 0; channel_idx<2; channel_idx++){
		
	image_name = "1_CH0"+channel_idx+"_"+tile_idx;
	open("C:/Users/MicroscopyInnovation/Desktop/Data/"+image_name+".tif");
	
	for (roi_idx=0; roi_idx<4; roi_idx++){
		selectWindow(image_name+".tif");
		
		// Create ROI for Processing on GPU
		if (roi_idx == 0) {
			makeRectangle(0, 0, 1024, 1024);
		} else if (roi_idx == 1){
			makeRectangle(1024, 0, 1024, 1024);
		} else if (roi_idx == 2){
			makeRectangle(1024, 1024, 1024, 1024);
		} else if (roi_idx == 3){
			makeRectangle(0, 1024, 1024, 1024);
		}
		run("Duplicate...", "duplicate"); 	
	
		// Select ROI
		roi_number = roi_idx + 1;
		selectWindow(image_name+"-"+1+".tif");
		input = getTitle();
		
		//Initialize Variables
		blurred = "blurred_"+channel_idx+"_"+roi_number;
	
		// Init GPU
		run("CLIJ2 Macro Extensions", "cl_device=");
		Ext.CLIJ2_clear();
		
		// push images to GPU
		Ext.CLIJ2_push(input);
		print("Imaged Pushed to GPU");
		close(image_name+".tif");
		
		// Difference of Gaussian to Identify Glomeruli
		time = getTime();
		sigma1 = 50;
		sigma2 = 100;
		Ext.CLIJ2_differenceOfGaussian3D(input, blurred, sigma1, sigma1, sigma1, sigma2, sigma2, sigma2);
		Ext.CLIJ2_pull(blurred);
		print("DoG Complete");
	}
}

// Multiply DoG Images
imageCalculator("Multiply create 32-bit stack", "blurred_0_1","blurred_1_1");
close("blurred_0_1");
close("blurred_1_1");
selectWindow("Result of blurred_0_1");
input1 = getTitle();

// Multiply DoG Images
imageCalculator("Multiply create 32-bit stack", "blurred_0_2","blurred_1_2");
close("blurred_0_2");
close("blurred_1_2");
selectWindow("Result of blurred_0_2");
input2 = getTitle();

// Multiply DoG Images
imageCalculator("Multiply create 32-bit stack", "blurred_0_3","blurred_1_3");
close("blurred_0_3");
close("blurred_1_3");
selectWindow("Result of blurred_0_3");
input3 = getTitle();

// Multiply DoG Images
imageCalculator("Multiply create 32-bit stack", "blurred_0_4","blurred_1_4");
close("blurred_0_4");
close("blurred_1_4");
selectWindow("Result of blurred_0_4");
input4 = getTitle();

// Initialize CLIJ2
run("CLIJ2 Macro Extensions", "cl_device=");
Ext.CLIJ2_clear();

// Push images to GPU
Ext.CLIJ2_push(input1);
output1 = "output1";
Ext.CLIJ2_thresholdHuang(input1, output1);
Ext.CLIJ2_pull(output1);
Ext.CLIJ2_clear();
close(input1);

Ext.CLIJ2_push(input2);
output2 = "output2";
Ext.CLIJ2_thresholdHuang(input2, output2);
Ext.CLIJ2_pull(output2);
Ext.CLIJ2_clear();
close(input2);

Ext.CLIJ2_push(input3);
output3 = "output3";
Ext.CLIJ2_thresholdHuang(input3, output3);
Ext.CLIJ2_pull(output3);
Ext.CLIJ2_clear();
close(input3);

Ext.CLIJ2_push(input4);
output4 = "output4";
Ext.CLIJ2_thresholdHuang(input4, output4);
Ext.CLIJ2_pull(output4);
Ext.CLIJ2_clear();
close(input4);


//Combine vertically
run("Combine...", "stack1=output1 stack2=output4 combine");
selectWindow("Combined Stacks");
rename("left");
run("Combine...", "stack1=output2 stack2=output3 combine");
selectWindow("Combined Stacks");
rename("right");

// Combine horizontally
run("Combine...", "stack1=left stack2=right");