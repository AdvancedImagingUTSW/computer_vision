
// Normalized Cell
open(data_path);
forethresh = getTitle();

// Calculate Otsu Threshold
setAutoThreshold("Otsu dark stack");
getThreshold(lower_threshold, upper_threshold);
run("Subtract...", "value="+lower_threshold+" stack");

// Calculate Standard Deviation
run("Set Measurements...", "standard redirect=None decimal=4");
run("Clear Results");
//selectWindow("1_CH00_000000.tif");
n = getSliceNumber();
for (i=1; i<=nSlices; i++) {
  	setSlice(i);
  	getStatistics(area, mean, min, max, std);
  	row = nResults;
  	setResult("Mean ", row, mean);
  	setResult("Std ", row, std);
  	setResult("Min ", row, min);
	setResult("Max ", row, max);
}
updateResults();
getResult("Column", row)

total_std=0;
for (i=0; i<nResults(); i++) {
    total_std=total_std+getResult("Std ",i);
}
mean_std=total_std/nResults;

// Divide by Standard Deviation
run("Divide...", "value="+mean_std+" stack");
print("Image Divided by Standard Deviation");

Ext.CLIJ2_push(temp12);
Ext.CLIJ2_push(forethresh);
Ext.CLIJ2_maximumImages(temp12, forethresh, combined_image);
Ext.CLIJ2_pull(combined_image);
