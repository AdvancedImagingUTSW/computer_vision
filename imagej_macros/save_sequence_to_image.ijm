// Read input file and output directory paths
args = getArgument()
args = split(args, " ");
input_directory = args[0];
output_file = args[1];

// Make sure the output directory ends with a file separator.
if (!endsWith(input_directory, File.separator))
{
    input_directory = input_directory + File.separator;
}

// Load the Data
run("Image Sequence...", "open="+input_directory+"masks.png file=mask sort");
saveAs("Tiff", output_file);

// quit after we are finished
eval("script", "System.exit(0);");