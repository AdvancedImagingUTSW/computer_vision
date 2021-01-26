data_directory = '/archive/MIL/dean/test';
downsampling_factor = 16;
verbose = 0;

/* An automated pipeline for identifying the number of positions, channels, and timepoints.
 *  Currently only set to hanle multiple positions and channels.
 *  Need to confirm why the lateral voxel size is used in one section.
 *  Ideally, scale up to be able to do mutiple time points. 
 *  Creates the XML file, saves to N5, and performs stitching.
 */

print("\\Clear");
// Append File Separator If Necessary
if (!endsWith(data_directory, File.separator)){
	data_directory = data_directory + File.separator;
	if (verbose) {
		print("Appending File Seperator");
	}
}

// Evaluate Number of Positions to Stitch
position_idx = 1;
position_path = data_directory+'position '+position_idx;

directory_exists = File.isDirectory(position_path);
if (!directory_exists) {
	print("Position Folder Not Found - Check Specified Data Directory");
}

while (File.isDirectory(position_path)) {
	if (verbose) {
		print(position_path+" Found");
	}
	position_idx++;
	position_path = data_directory+'position '+position_idx;
}
number_of_positions = position_idx-1;
print(number_of_positions+" Positions Found");

// Evaluate Number of Channels to Stitch
channel_idx = 0;
channel_path = data_directory+'position 1/1_CH0'+channel_idx+'_000000.tif';
file_exists = File.exists(channel_path);
if (!file_exists) {
	print(channel_path+" Not Found");
}
while (File.exists(channel_path)) {
	channel_idx++;
	channel_path = data_directory+'position 1/1_CH0'+channel_idx+'_000000.tif';
}
number_of_channels = channel_idx-1;
print(number_of_channels+1+" Channel Dataset");

// Evaluate Number of Time Points to Stitch
time_idx = 0;
padded_time_idx = IJ.pad(time_idx,6);
time_path = data_directory+'position 1/1_CH00_'+padded_time_idx+'.tif';
if (!file_exists) {
	print(time_path+" Not Found");
}

while (File.exists(time_path)) {
	time_idx++;
	padded_time_idx = IJ.pad(time_idx,6);
	time_path = data_directory+'position 1/1_CH00_'+padded_time_idx+'.tif';
}

number_of_timepoints = time_idx;
print(number_of_timepoints+" Timepoint Dataset");

// Confirm That All Files Are Present
time_idx = 0;
for (position_idx = 1; position_idx < number_of_positions+1; position_idx++) {
	for (channel_idx = 0; channel_idx < number_of_channels; channel_idx++) {
		for (time_idx = 0; time_idx < number_of_timepoints; time_idx++) {
			file_path = data_directory+'position '+position_idx+'/1_CH0'+channel_idx+'_'+IJ.pad(time_idx,6)+'.tif';
			if (!File.exists(file_path)) {
				exit('File Missing: '+file_path);
			}
			file_path = data_directory+'position '+position_idx+'/AcqInfo.txt';
			if (!File.exists(file_path)) {
				exit('File Missing: '+file_path);
			}
		}
	}
}
print("All Files Found");

// Find Proper Text Indices
file_path = data_directory+'position 1/AcqInfo.txt';
file_string = File.openAsString(file_path);
rows = split(file_string, "\n");
for (text_idx = 0; text_idx < rows.length; text_idx++) {
	if (matches(substring(rows[text_idx], 0, 5), 'SizeX')) {
		x_idx = text_idx;
		if (verbose) {
			print("The SizeX index is at " + x_idx);
		}
		x_idx = floor(x_idx);
	}
	if (matches(substring(rows[text_idx], 0, 5), 'SizeY')) {
		y_idx = text_idx;
		if (verbose) {
			print("The SizeY index is at " + y_idx);
		}
		y_idx = floor(y_idx);
	}	
	if (matches(substring(rows[text_idx], 0, 5), 'SizeZ')) {
		z_idx = text_idx;
		if (verbose) {
			print("The SizeZ index is at " + z_idx);
		}
		z_idx = floor(z_idx);
	}
	if (startsWith(rows[text_idx], 'PhysicalSizeX')) {
		lateral_size_idx = text_idx;
		if (verbose) {
			print("The PhysicalSizeX index is at " + lateral_size_idx);
		}
		lateral_size_idx = floor(lateral_size_idx);
	}
	if (startsWith(rows[text_idx], 'PhysicalSizeZ')) {
		axial_size_idx = text_idx;
		if (verbose) {
			print("The PhysicalSizeZ index is at " + axial_size_idx);
		}
		axial_size_idx = floor(axial_size_idx);
	}
	if (startsWith(rows[text_idx], 'PositionX')) {
		x_pos_idx = text_idx;
		if (verbose) {
			print("The PositionX index is at " + x_pos_idx);
		}
		x_pos_idx = floor(x_pos_idx);
	}
	if (startsWith(rows[text_idx], 'PositionY')) {
		y_pos_idx = text_idx;
		if (verbose) {
			print("The PositionY index is at " + y_pos_idx);
		}
		y_pos_idx = floor(y_pos_idx);
	}
	if (startsWith(rows[text_idx], 'PositionZ')) {
		z_pos_idx = text_idx;
		if (verbose) {
			print("The PositionZ index is at " + z_pos_idx);
		}
		z_pos_idx = floor(z_pos_idx);
	}
}

// Determine Voxel Size
size_x = substring(rows[x_idx], indexOf(rows[x_idx], '= ')+2, rows[x_idx].length);
size_y = substring(rows[y_idx], indexOf(rows[y_idx], '= ')+2, rows[y_idx].length);
size_z = substring(rows[z_idx], indexOf(rows[z_idx], '= ')+2, rows[z_idx].length);
lateral_pixel_size = substring(rows[lateral_size_idx], indexOf(rows[lateral_size_idx], '= ')+2, rows[lateral_size_idx].length);
axial_pixel_size = substring(rows[axial_size_idx], indexOf(rows[axial_size_idx], '= ')+2, rows[axial_size_idx].length);
print("Image is "+size_x+"x"+size_y+"x"+size_z+" pixels");
print("Voxel Dimensions: "+lateral_pixel_size+"x"+axial_pixel_size+" microns");

// Convert to Integers
size_x = parseInt(size_x);
size_y = parseInt(size_y);
size_z = parseInt(size_z);
lateral_pixel_size = parseFloat(lateral_pixel_size);
axial_pixel_size = parseFloat(axial_pixel_size);
pixel_ratio = axial_pixel_size/lateral_pixel_size;

// Collect all of the Image Positions
print("Evaluating Image Positions");
x_locations = newArray(number_of_positions);
y_locations = newArray(number_of_positions);
z_locations = newArray(number_of_positions);
for (position_idx = 1; position_idx < number_of_positions+1; position_idx++) {
	file_path = data_directory+'position '+position_idx+'/AcqInfo.txt';
	file_string = File.openAsString(file_path);
	rows = split(file_string, "\n");
	
	temp = substring(rows[x_pos_idx], indexOf(rows[x_pos_idx], '= ')+2, rows[x_pos_idx].length);
	temp = parseFloat(temp);
	x_locations[position_idx-1] = temp*pixel_ratio;
	
	temp = substring(rows[y_pos_idx], indexOf(rows[y_pos_idx], '= ')+2, rows[y_pos_idx].length);
	temp = parseFloat(temp);
	y_locations[position_idx-1] = temp*pixel_ratio;
	
	temp = substring(rows[z_pos_idx], indexOf(rows[z_pos_idx], '= ')+2, rows[z_pos_idx].length);
	temp = parseFloat(temp);
	z_locations[position_idx-1] = temp*pixel_ratio;
}

// Make the XML File for BigStitcher
print("Generating XML File");
if (File.exists(data_directory+'dataset.xml')) {
	File.delete(data_directory+'dataset.xml');
}

//Specify Image Loader
fileID=File.open(data_directory+'dataset.xml');
print(fileID,'<?xml version="1.0" encoding="UTF-8"?>\n');
print(fileID,'<SpimData version="0.2">\n');
print(fileID,' <BasePath type="relative">.</BasePath>\n');
print(fileID,' <SequenceDescription>\n');
print(fileID,'  <ImageLoader format="spimreconstruction.stack.ij">\n');
print(fileID,'   <imagedirectory type="relative">.</imagedirectory>\n');
print(fileID,'   <filePattern>position {x}/1_CH0{c}_000000.tif</filePattern>\n');
print(fileID,'   <layoutTimepoints>0</layoutTimepoints>\n');
print(fileID,'   <layoutChannels>'+number_of_channels+'</layoutChannels>\n');
print(fileID,'   <layoutIlluminations>0</layoutIlluminations>\n');
print(fileID,'   <layoutAngles>0</layoutAngles>\n');
print(fileID,'   <layoutTiles>1</layoutTiles>\n');
print(fileID,'   <imglib2container>ArrayImgFactory</imglib2container>\n');
print(fileID,'  </ImageLoader>\n');

// Define Views
print(fileID,'  <ViewSetups>\n');
id_idx = 0;
for (channel_idx = 0; channel_idx < number_of_channels+1; channel_idx++) {
	for (position_idx = 0; position_idx < number_of_positions; position_idx++) {
		print(fileID,'   <ViewSetup>\n');
	    print(fileID,'    <id>'+id_idx+'</id>\n');
	    print(fileID,'    <name>'+id_idx+'</name>\n');
	    print(fileID,'    <size>'+size_x+' '+size_y+' '+size_z+'</size>\n');
	    print(fileID,'    <voxelSize>\n');
	    print(fileID,'     <unit>um</unit>\n');
	    print(fileID,'     <size>'+d2s(lateral_pixel_size,3)+' '+d2s(lateral_pixel_size,3)+' '+d2s(axial_pixel_size,3)+'</size>\n');
	    print(fileID,'    </voxelSize>\n');
	    print(fileID,'    <attributes>\n');
	    print(fileID,'     <illumination>0</illumination>\n');
	    print(fileID,'     <channel>'+channel_idx+'</channel>\n');
	    print(fileID,'     <tile>'+floor(position_idx)+'</tile>\n');
	    print(fileID,'     <angle>0</angle>\n');
	    print(fileID,'    </attributes>\n');
	    print(fileID,'   </ViewSetup>\n');
	    id_idx++;
	}
}

// Illumination Attributes
print(fileID,'   <Attributes name="illumination">\n');
print(fileID,'    <Illumination>\n');
print(fileID,'     <id>0</id>\n');
print(fileID,'     <name>0</name>\n');
print(fileID,'    </Illumination>\n');
print(fileID,'   </Attributes>\n');

// Channel Attributes
print(fileID,'   <Attributes name="channel">\n');
for (channel_idx = 0; channel_idx < number_of_channels+1; channel_idx++) {
	print(fileID,'    <Channel>\n');
	print(fileID,'     <id>'+channel_idx+'</id>\n');
	print(fileID,'     <name>'+channel_idx+'</name>\n');
	print(fileID,'    </Channel>\n');
}	
print(fileID,'   </Attributes>\n');

// Tile Attributes
print(fileID,'   <Attributes name="tile">\n');
for (position_idx = 0; position_idx < number_of_positions; position_idx++) {
    print(fileID,'    <Tile>\n');
    print(fileID,'     <id>'+floor(position_idx)+'</id>\n');
    print(fileID,'     <name>'+floor(position_idx+1)+'</name>\n');
    print(fileID,'    </Tile>\n');
}
print(fileID,'   </Attributes>\n');

// Angle
print(fileID,'   <Attributes name="angle">\n');
print(fileID,'    <Angle>\n');
print(fileID,'     <id>0</id>\n');
print(fileID,'     <name>0</name>\n');
print(fileID,'    </Angle>\n');
print(fileID,'   </Attributes>\n');
print(fileID,'  </ViewSetups>\n');

// Time
print(fileID,'  <Timepoints type="pattern">\n');
print(fileID,'   <integerpattern />\n');
print(fileID,'  </Timepoints>\n');
print(fileID,' </SequenceDescription>\n');

// View Registrations - Need to look into this.  Why is it that all three have the lateral pixel size?
print(fileID,' <ViewRegistrations>\n');
setup_idx = 0;
for (channel_idx = 0; channel_idx < number_of_channels+1; channel_idx++) {
	for (position_idx = 0; position_idx < number_of_positions; position_idx++) {
	    print(fileID,'  <ViewRegistration timepoint="0" setup="'+setup_idx+'">\n');
	    print(fileID,'   <ViewTransform type="affine">\n');
	    print(fileID,'    <Name>calibration</Name>\n');
	
		x = x_locations[position_idx]/lateral_pixel_size;
		y = y_locations[position_idx]/lateral_pixel_size;
		z = z_locations[position_idx]/lateral_pixel_size;
	
	    print(fileID,'    <affine>1.0 0.0 0.0 '+d2s(x,4)+' 0.0 1.0 0.0 '+d2s(y,4)+' 0.0 0.0 1.0 '+d2s(z,4)+'</affine>\n');
	    print(fileID,'   </ViewTransform>\n');
	    
	    print(fileID,'   <ViewTransform type="affine">\n');
	    print(fileID,'    <Name>calibration</Name>\n');
	    print(fileID,'    <affine>1.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0 '+d2s(pixel_ratio,4)+'</affine>\n');
	    print(fileID,'   </ViewTransform>\n');
	    print(fileID,'  </ViewRegistration>\n');
	    setup_idx++;
	}
}
print(fileID,' </ViewRegistrations>\n');

// Unused Features
print(fileID,' <ViewInterestPoints />\n');
print(fileID,' <BoundingBoxes />\n');
print(fileID,' <PointSpreadFunctions />\n');
print(fileID,' <StitchingResults />\n');
print(fileID,' <IntensityAdjustments />\n');
print(fileID,'</SpimData>\n');

File.close(fileID);

/*

// Resave data as a a compressed N5 file.
run("As N5 ...", 
	"select="+data_directory+"dataset.xml" +
	" resave_angle=[All angles] "+ 
	"resave_channel=[All channels] "+
	"resave_illumination=[All illuminations] "+
	"resave_tile=[All tiles] "+
	"resave_timepoint=[All Timepoints] "+
	"compression=[Raw (no compression)] "+
	"subsampling_factors=[{ {1,1,1}, {2,2,2}, {4,4,4}, {8,8,8} }] "+
	"n5_block_sizes=[{ {128,128,64}, {128,128,64}, {128,128,64}, {128,128,64} }] "+
	"output_xml="+data_directory+"dataset-n5.xml "+
	"output_n5="+data_directory+"dataset.n5 write_xml write_data");


// Calculate Pairwise Shifts
run("Calculate pairwise shifts ...", 
	"select="+data_directory+"dataset-n5.xml" +
	" process_angle=[All angles]" +
	" process_channel=[All channels]" +
	" process_illumination=[All illuminations]" +
	" process_tile=[Range of tiles (Specify by Name)]" +
	" process_timepoint=[All Timepoints]" +
	" process_following_tiles=[All Tiles]" +
	" method=[Phase Correlation]" +
	" show_expert_grouping_options how_to_treat_timepoints=[treat individually]" +
	" channels=[Average Channels]" +
	" how_to_treat_illuminations=group how_to_treat_angles=[treat individually]" +
	" how_to_treat_tiles=compare" +
	" downsample_in_x=2 downsample_in_y=2 downsample_in_z=2");
	print("Pairwise Shift Complete");

// Filter Pairwise Shifts
run("Filter pairwise shifts ...", 
	"select="+data_directory+"dataset-n5.xml" +
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
	"select="+data_directory+"dataset-n5.xml" +
	" process_angle=[All angles]" +
	" process_channel=[All channels]" +
	" process_illumination=[All illuminations]" +
	" process_tile=[Range of tiles (Specify by Name)]" +
	" process_timepoint=[All Timepoints]" +
	" process_following_tiles=[All tiles]" +
	" relative=2.500" +
	" absolute=3.500" +
	" global_optimization_strategy=[One-Round with iterative dropping of bad links]" +
	" fix_group_0-0");
	print("Shifts Globally Optimized");


// Create Export Directory
save_directory = data_directory + "fused_"+downsampling_factor+"x_downsampled";
if (!endsWith(save_directory, File.separator)) {
		save_directory = save_directory + File.separator;
}
File.makeDirectory(save_directory)

// Fuse the Dataset
run("Fuse dataset ...", 
	"select="+data_directory+"dataset-n5.xml" +
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

for (slice_idx=1; slice_idx<slices+1; slice_idx++) {
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

/*

 */