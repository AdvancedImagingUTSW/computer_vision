// Load CLIJ Extensions
run("CLIJ2 Macro Extensions", "cl_device=[Tesla V100-PCIE-32GB]");

for (image_idx = 1; image_idx < 52; image_idx++) {

	// Specify Data Location
	image_number=IJ.pad(image_idx, 6);
	image_name="1_CH00_"+image_number+".tif";
	data_path = "/archive/MIL/marciano/20201211_CapillaryLooping/cropped/mutant/";
	
	// Specify Unique Handling
	fill_holes_slice_by_slice = 0;
	huang_threshold = 1;
	
	// Clear Workspace & GPU Memory
	close("*");
	Ext.CLIJ2_clear();
	
	// Load Data
	open(data_path+image_name);
	print("Processing Image: "+image_name);
	
	// Noise Removal
	sigma = 1;
	Ext.CLIJ2_push(image_name);
	Ext.CLIJ2_gaussianBlur3D(image_name, temp1, sigma, sigma, sigma);
	
	// Background Removal
	sigma = 20;
	Ext.CLIJx_subtractGaussianBackground(temp1, temp2, sigma, sigma, sigma);
	
	// Gamma Correction
	gamma = 0.5;
	Ext.CLIJx_gammaCorrection(temp2, temp3, gamma);
	
	// Otsu Threshold
	if (huang_threshold) {
		Ext.CLIJ2_thresholdHuang(temp3, temp4);
	};
	else {
		Ext.CLIJ2_thresholdOtsu(temp3, temp4);
	};
	
	
	// Fill Holes
	if (fill_holes_slice_by_slice) {
		// Slice by Slice
		Ext.CLIJx_binaryFillHolesSliceBySlice(temp4, temp5);
	};
		else {
		// In 3D
		Ext.CLIJ2_binaryFillHoles(temp4, temp5);
	};
	
	// Image Erosion
	Ext.CLIJ2_erodeSphere(temp5, temp6);
	
	// Create Mask
	Ext.CLIJ2_connectedComponentsLabelingBox(temp6, labelmap);
	
	// Measure Label Properties
	run("Clear Results");
	Ext.CLIJ2_statisticsOfBackgroundAndLabelledPixels(image_name, labelmap);
	
	// Find Largest Feature
	print("Features Detected: "+nResults());
	max_voxels = 0;
	max_index = 0;
	for (i=1; i<nResults(); i++) {
	    if (getResult("PIXEL_COUNT",i)>max_voxels){
	    	max_voxels = getResult("PIXEL_COUNT",i);
	    	max_index = i;
	    }
	    	else{};
	}
	
	print("The Maximum Non-Background Feature is "+max_index);
	print("The Maximum Number of Voxels is "+max_voxels);
	
	// Pull Image
	Ext.CLIJ2_pull(labelmap);
	rename("labelmap");
	
	// Threshold Out the Label of Interest
	run("Manual Threshold...", "min="+max_index+" max="+max_index);
	run("Make Binary", "method=Default background=Default");
	
	// Save Binary Image
	export_name = substring(image_name, 0, indexOf(image_name, ".tif"))+"_binary.tif";
	saveAs("Tiff", data_path+export_name);
	
	// Skeletonize
	run("Skeletonize (2D/3D)");
	
	// Lowest Intensity Voxel Pruning of the Skeleton
	run("Analyze Skeleton (2D/3D)", "prune=[lowest intensity voxel] prune_0 show display original_image="+image_name);
	rename("skeleton");
	
	export_name = substring(image_name, 0, indexOf(image_name, ".tif"))+"_skeleton.tif";
	saveAs("Tiff", data_path+export_name);
	
	export_name = substring(image_name, 0, indexOf(image_name, ".tif"))+"_results.csv";
	saveAs("Results", data_path+export_name);
	run("Close");
	
	export_name = substring(image_name, 0, indexOf(image_name, ".tif"))+"_branch_info.csv";
	saveAs("Results", data_path+export_name);
	run("Close All");

}