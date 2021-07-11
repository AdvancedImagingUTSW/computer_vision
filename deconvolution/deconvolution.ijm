/*Deconvolution Pipeline
 * Based off of Clijx.
 * Requires gcc/8.3.0 to be loaded in the terminal prior to launching Fiji.
 * Also had some specific dependencies that had to be placed in the Fiji folder: https://www.dropbox.com/sh/dxofkiyseuxn4l4/AADkIeK3nD5SW7EOsURoQoAGa?dl=0
 * https://forum.image.sc/t/clij-deconvolution/35172/94
 */

verbose = 1;
num_iterations = 20.0;
regularization = 0;
non_circulant = 0;

// Initialize CLIJ
// run("CLIJ2 Macro Extensions", "cl_device=[]");
run("CLIJ2 Macro Extensions", "cl_device=[Tesla V100-PCIE-32GB]");
Ext.CLIJ2_clear();
close("*");

if (verbose) {
	run("Console");
	run("GPU Memory Display (experimental)");
}

// Load the Image to Deconvolve
directory = "/archive/MIL/dean/20210311_u54/";
i=0;
// image = "1_CH00_"+IJ.pad(i, 6)+".tif";
image="C2-Composite-1.tif";
open(directory+image);
image1 = getTitle();
Ext.CLIJ2_push(image1);

// Load the PSF
open("/archive/MIL/dean/PSF/ctASLM2/ctASLM2-510nm.tif");
// open("/archive/MIL/ly/bld1/GFPsuntag-mChH2B/210211/PSF.tif");
image2 = getTitle();
Ext.CLIJ2_push(image2);

// Deconvolve the Data
time = getTime();
image3 = "deconvolve_richardson_lucy_f_f_t-1285284569";
Ext.CLIJx_deconvolveRichardsonLucyFFT(image1, image2, image3, num_iterations, regularization, non_circulant);

// Pull the Data
Ext.CLIJ2_pull(image3);
if (verbose) {
	print("Deconvolving one image on the GPU took " + (getTime() - time) + " msec");
}

// export_name = substring(image, 0, indexOf(image, ".tif"))+"_decon.h5";

// run("Export HDF5", "select="+directory+export_name+" exportpath="+directory+export_name+" datasetname=data compressionlevel=0 input=deconvolve_richardson_lucy_f_f_t-1285284569");
// close("*");
