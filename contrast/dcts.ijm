close("*");
image_name = '1_CH00_000000.tif';
image_path = '/archive/MIL/marciano/20201211_CapillaryLooping/cropped/mutant/';

open(image_path+image_name);
time = getTime();
run("Image Focus Measurements slice by slice (Adapted Autopilot code, Royer et Al. 2016)", "plot normalized_dct_shannon_entropy currentdata="+image_name);
print("Measuring the DCT took " + (getTime() - time) + " msec");

saveAs("Results", "/home2/kdean/Desktop/Results.csv");