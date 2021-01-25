data_directory = '/archive/MIL/dean/test';

verbose = 0;

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
number_of_channels = channel_idx;
print(number_of_channels+" Channel Dataset");

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

// Move Files to a Common Directory


// Collect all of the Image Positions
// I need to find a way to automatically identify the proper indices.
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

fileID=File.open(data_directory+'dataset.xml');
print(fileID,'<?xml version="1.0" encoding="UTF-8"?> \n');
print(fileID,'<SpimData version="0.2"> \n');
print(fileID,'\t<BasePath type="relative">.</BasePath> \n');
print(fileID,'\t<SequenceDescription>\n');
print(fileID,'\t\t<ImageLoader format="spimreconstruction.stack.ij"> \n');
print(fileID,'\t\t\t<imagedirectory type="relative">.</imagedirectory> \n');
print(fileID,'\t\t\t<filePattern>1_CH00_{x}.tif</filePattern> \n');
print(fileID,'\t\t\t<layoutTimepoints>0</layoutTimepoints> \n');
print(fileID,'\t\t\t<layoutChannels>0</layoutChannels> \n');
print(fileID,'\t\t\t<layoutIlluminations>0</layoutIlluminations> \n');
print(fileID,'\t\t\t<layoutAngles>0</layoutAngles> \n');
print(fileID,'\t\t\t<layoutTiles>1</layoutTiles> \n');
print(fileID,'\t\t\t<imglib2container>ArrayImgFactory</imglib2container> \n');
print(fileID,'\t\t</ImageLoader> \n');
print(fileID,'\t\t<ViewSetups>\n');

for (position_idx = 1; position_idx < number_of_positions+1; position_idx++) {
	print(fileID,'\t\t\t<ViewSetup>\n');
    print(fileID,'\t\t\t\t<id>'+floor(position_idx-1)+'</id>\n');
    print(fileID,'\t\t\t\t<name>'+floor(position_idx-1)+'</name>\n');
    print(fileID,'\t\t\t\t<size>'+size_x+' '+size_y+' '+size_z+'</size>\n');
    print(fileID,'\t\t\t\t<voxelSize>\n');
    print(fileID,'\t\t\t\t\t<unit>um</unit>\n');
    print(fileID,'\t\t\t\t\t<size>'+d2s(lateral_pixel_size,3)+' '+d2s(lateral_pixel_size,3)+' '+d2s(axial_pixel_size,3)+'</size> \n');
    print(fileID,'\t\t\t\t</voxelSize>\n');
    print(fileID,'\t\t\t\t<attributes>\n');
    print(fileID,'\t\t\t\t\t<illumination>0</illumination>\n');
    print(fileID,'\t\t\t\t\t<channel>0</channel>\n');
    print(fileID,'\t\t\t\t\t<tile>'+floor(position_idx-1)+'</tile>\n');
    print(fileID,'\t\t\t\t\t<angle>0</angle>\n');
    print(fileID,'\t\t\t\t</attributes>\n');
    print(fileID,'\t\t\t</ViewSetup>\n');
}

print(fileID,'\t\t\t<Attributes name="illumination">\n');
print(fileID,'\t\t\t\t<Illumination>\n');
print(fileID,'\t\t\t\t\t<id>0</id>\n');
print(fileID,'\t\t\t\t\t<name>0</name>\n');
print(fileID,'\t\t\t\t</Illumination>\n');
print(fileID,'\t\t\t</Attributes>\n');
print(fileID,'\t\t\t<Attributes name="channel">\n');
print(fileID,'\t\t\t\t<Channel>\n');
print(fileID,'\t\t\t\t\t<id>0</id>\n');
print(fileID,'\t\t\t\t\t<name>0</name>\n');
print(fileID,'\t\t\t\t</Channel>\n');

print(fileID,'\t\t\t</Attributes>\n');
print(fileID,'\t\t\t<Attributes name="tile">\n');
for (position_idx = 1; position_idx < number_of_positions+1; position_idx++) {
    print(fileID,'\t\t\t\t<Tile>\n');
    print(fileID,'\t\t\t\t\t<id>'+d2s(position_idx-1,4)+'</id>\n');
    print(fileID,'\t\t\t\t\t<name>'+d2s(position_idx,4)+'</name>\n');
    print(fileID,'\t\t\t\t</Tile>\n');
}
print(fileID,'\t\t\t</Attributes>\n');

// Angle
print(fileID,'\t\t\t<Attributes name="angle">\n');
print(fileID,'\t\t\t\t<Angle>\n');
print(fileID,'\t\t\t\t\t<id>0</id>\n');
print(fileID,'\t\t\t\t\t<name>0</name>\n');
print(fileID,'\t\t\t\t</Angle>\n');
print(fileID,'\t\t\t</Attributes>\n');
print(fileID,'\t\t</ViewSetups>\n');

// Time
print(fileID,'\t\t<Timepoints type="pattern">\n');
print(fileID,'\t\t\t<integerpattern />\n');
print(fileID,'\t\t</Timepoints>\n');

// Missing Views and Close Out Sequence Description
print(fileID,'\t\t<MissingViews />');
print(fileID,'\t</SequenceDescription>\n');

// Registration
print(fileID,'\t<ViewRegistrations>\n');

// Need to look into this.  Why is it that all three have the lateral pixel size?
for (position_idx = 1; position_idx < number_of_positions+1; position_idx++) {
    print(fileID,'\t\t<ViewRegistration timepoint="0" setup="'+floor(position_idx-1)+'">\n');
    print(fileID,'\t\t\t<ViewTransform type="affine">\n');
    print(fileID,'\t\t\t\t<Name>Translation from Tile Configuration</Name>\n');

	x = x_locations[position_idx-1]/lateral_pixel_size;
	y = y_locations[position_idx-1]/lateral_pixel_size;
	z = z_locations[position_idx-1]/lateral_pixel_size;

    print(fileID,'\t\t\t\t<affine>1.0 0.0 0.0 '+d2s(x,4)+' 0.0 1.0 0.0 '+d2s(y,4)+' 0.0 0.0 1.0 '+d2s(z,4)+'</affine>\n');
    print(fileID,'\t\t\t</ViewTransform>\n');
    print(fileID,'\t\t\t<ViewTransform type="affine">\n');
    print(fileID,'\t\t\t\t<Name>calibration</Name>\n');
    print(fileID,'\t\t\t\t<affine>1.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0 '+d2s(pixel_ratio,4)+'</affine>\n');
    print(fileID,'\t\t\t</ViewTransform>\n');
    print(fileID,'\t\t</ViewRegistration>  \n');
}

print(fileID,'\t</ViewRegistrations>\n');
print(fileID,'\t<ViewInterestPoints />\n');
print(fileID,'\t<BoundingBoxes />\n');
print(fileID,'\t<PointSpreadFunctions />\n');
print(fileID,'\t<StitchingResults />\n');
print(fileID,'\t<IntensityAdjustments />\n');
print(fileID,'</SpimData> \n');

File.close(fileID);