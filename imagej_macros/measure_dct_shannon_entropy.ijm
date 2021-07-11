root_dir='/archive/MIL/marciano/20210302_cropped_volumes/20210119_wt/';
number_of_cells = 40;

for (i = 1; i <= number_of_cells; i++) {
	
	image_number=IJ.pad(i, 6);
	image_name='1_CH01_'+image_number;
	
	open(root_dir+image_name+".tif");
	run("Image Focus Measurements slice by slice (Adapted Autopilot code, Royer et Al. 2016)", "normalized_dct_shannon_entropy");
	saveAs("Results", root_dir+image_name+".csv");
	run("Close All");
	run("Clear Results");
}
