basePath = "/project/bioinformatics/Danuser_lab/microscopeDevelopment/raw/CleardTissueScope/Data/Morrison/Tonmoy_Test/BoneMarrowNniche/Test/190628/Cell1_imageFlip";

if (!endsWith(basePath, File.separator))
{
    basePath = basePath + File.separator;
}

// What File Properties?
numberOfTiles = 12;
lateralPixelSize = 0.167;
axialPixelSize = 0.995;


// For Export, Which Planes?  What Downsampling?
downSamplingFactor = 16;
startPlane = 1;
endPlane = 5;

// Resave as HDF5
//run("As HDF5 ...", 
//	"select="+basePath+"dataset.xml" +
//	" resave_angle=[All angles]" +
//	" resave_channel=[All channels]" +
//	" resave_illumination=[All illuminations]" +
//	" resave_tile=[All tiles]" +
//	" resave_timepoint=[All Timepoints]" +
//	" subsampling_factors=[{ {1,1,1}, {2,2,2}}]" +
//	" hdf5_chunk_sizes=[{ {16,16,16}, {16,16,16}}]" +
//	" timepoints_per_partition=1" +
//	" setups_per_partition=0" +
//	" use_deflate_compression" +
//	" export_path="+basePath+"dataset.xml");
	print("HDF5 Complete");

// Calculate Pairwise Shifts
startIdx = 1;
endIdx = 12;

run("Calculate pairwise shifts ...", 
	"select="+basePath+"dataset.xml" +
	" process_angle=[All angles]" +
	" process_channel=[All channels]" +
	" process_illumination=[All illuminations]" +
	" process_tile=[Range of tiles (Specify by Name)]" +
	" process_timepoint=[All Timepoints]" +
	" process_following_tiles="+startIdx+"-"+endIdx+":1" +
	" method=[Phase Correlation]" +
	" show_expert_grouping_options how_to_treat_timepoints=[treat individually]" +
	" channels=[Average Channels]" +
	" how_to_treat_illuminations=group how_to_treat_angles=[treat individually]" +
	" how_to_treat_tiles=compare" +
	" downsample_in_x=2 downsample_in_y=2 downsample_in_z=2");
	print("Pairwise Shift Complete");

// Filter Pairwise Shifts
run("Filter pairwise shifts ...", 
	"select="+basePath+"dataset.xml" + 
	" filter_by_link_quality" +
	" min_r=0.85" + 
	" max_r=1" +
	" max_shift_in_x=0" +
	" max_shift_in_y=0" +
	" max_shift_in_z=0" +
	" max_displacement=0");
	print("Shifts Filtered");

// Optimize Globally
run("Optimize globally and apply shifts ...", 
	"select="+basePath+"dataset.xml" + 
	" process_angle=[All angles]" +
	" process_channel=[All channels]" +
	" process_illumination=[All illuminations]" +
	" process_tile=[Range of tiles (Specify by Name)]" +
	" process_timepoint=[All Timepoints]" +
	" process_following_tiles=1-"+numberOfTiles+":1" +
	" relative=2.500" +
	" absolute=3.500" +
	" global_optimization_strategy=[One-Round with iterative dropping of bad links]" +
	" fix_group_0-0");
	print("Shifts Globally Optimized");

// Fuse the Dataset
run("Fuse dataset ...", "select="+basePath+"dataset.xml" +
	" process_angle=[All angles]" +
	" process_channel=[All channels]" +
	" process_illumination=[All illuminations]" +
	" process_tile=[All tiles]" +
	" process_timepoint=[All Timepoints]" +
	" bounding_box=[Currently Selected Views]" +
	" downsampling="+downSamplingFactor +
	" pixel_type=[16-bit unsigned integer]" +
	" interpolation=[Linear Interpolation]" +
	" image=Virtual" +
	" blend preserve_original" +
	" produce=[Each timepoint & channel]" +
	" fused_image=[Display using ImageJ]");

// Export Individual Planes
savePath = basePath + "fusedData";
File.makeDirectory(savePath);
if (!endsWith(savePath, File.separator))
	{
    		savePath = savePath + File.separator;
	}

for (i=startPlane; i<(endPlane+1); i++) 
	{
		imNumber = i;
		run("Duplicate...",
		"title=temp duplicate range="+imNumber+"-"+imNumber+" use");
		saveAs("Tiff", savePath+imNumber+".tif");
		close();
	}

eval("script", "System.exit(0);");

