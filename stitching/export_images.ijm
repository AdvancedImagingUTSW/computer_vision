data_directory = '/archive/MIL/dauer/Lauren/Striatum/nanoAntiGFP-AF488/210401/Cell2/';
downsampling_factor = 1;
start_idx = 1;

// Create Export Directory
save_directory = data_directory + "fused_"+downsampling_factor+"x_downsampled";
if (!endsWith(save_directory, File.separator)) {
		save_directory = save_directory + File.separator;
}
print(save_directory);
File.makeDirectory(save_directory);

// Fuse the Dataset
run("Fuse dataset ...", 
	"select="+data_directory+"dataset2.xml" +
	" process_angle=[All angles]" +
	" process_channel=[All channels]" +
	" process_illumination=[All illuminations]" +
	" process_tile=[All tiles]" +
	" process_timepoint=[All Timepoints]" +
	" bounding_box=[Currently Selected Views]" +
	" downsampling="+downsampling_factor +
	" pixel_type=[16-bit unsigned integer]" +
	" interpolation=[Linear Interpolation]" +
	" image=Virtual" +
	" blend preserve_original" +
	" produce=[Each timepoint & channel]" +
	" fused_image=[Display using ImageJ]");

// Export Individual Slices
getDimensions(w, h, channels, slices, frames);
print("Number Of Slices = "+slices);

for (slice_idx=start_idx; slice_idx<slices+1; slice_idx++) {
	image_name = save_directory+slice_idx+".tif";
	if (File.exists(image_name)) {
		print("Image "+image_name+" already exists"); 
	}
	if (!File.exists(image_name)) {
		run("Duplicate...",
		"title=temp duplicate range="+slice_idx+"-"+slice_idx+" use");
		saveAs("Tiff", save_directory+slice_idx+".tif");
		close();
	}
}

// Processing Complete
close("*");
// eval("script", "System.exit(0);");