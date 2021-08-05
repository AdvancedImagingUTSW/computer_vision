base_path = "/archive/MIL/morrison/Sample2_SMA_tomato/488-561-640/210624/Cell1/mips/";
for (i = 0; i < 3; i++) {
	for (j = 1; j < 287; j++) {
		path = base_path+"1_CH0"+i+"_"+j+".tif";
		if (!File.exists(path)) {
			print("Path DNI: "+path);
		}
	}
}
		
