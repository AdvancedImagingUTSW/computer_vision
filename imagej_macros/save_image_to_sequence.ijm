// Read input file and output directory paths
args = getArgument()
args = split(args, " ");
input_file = args[0];
output_directory = args[1];
print(input_file);
print(output_directory);

// Make sure the output directory ends with a file separator.
if (!endsWith(output_directory, File.separator))
{
    output_directory = output_directory + File.separator;
}

// Load the Data
open(input_file);
print("Data Loaded");
run("Image Sequence... ", "format=TIFF name=[img_] save="+output_directory+"0000.tif");
close("*");

// quit after we are finished
eval("script", "System.exit(0);");