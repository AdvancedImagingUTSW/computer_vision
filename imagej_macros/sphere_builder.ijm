// This macro builds a 3D sphere in an image stack.
// Check 'Surface only' to get only the surface of the sphere.
// Authors: G. Hernan Sendra and Holger Lorenz
// ZMBH University of Heidelberg, Germany

macro "sphere_builder" {

// Default values
Width = 100; 
Height = 100; 
Slices = 100; 
Name = "Sphere"; 
x0 = 50; 
y0 = 50; 
z0 = 50; 
Radius = 25; 
OnlySurface=false;  // Only Surface?

// Check if you want dialog
UseDialog = true;

// Macro start
if (UseDialog) {
	Dialog.create ("build sphere");
	Dialog.addMessage ("Set image and sphere dimensions");
	Dialog.addNumber ("Image width:", Width); //number 1
	Dialog.addNumber ("Image height:", Height); //number 2
	Dialog.addNumber ("Number of slices:", Slices); //number 3
	Dialog.addString ("Name:", Name); //number 4
	Dialog.addNumber ("Sphere center x0:", x0); //number 5
	Dialog.addNumber ("Sphere center y0:", y0); //number 6
	Dialog.addNumber ("Sphere center z0:", z0); //number 7
	Dialog.addNumber ("Radius:", Radius); //number 8
	Dialog.addCheckbox ("Surface only? Check if yes!", OnlySurface); //check 1
	
	Dialog.show ();
	
	Width = Dialog.getNumber (); //1
	Height = Dialog.getNumber (); //2
	Slices = Dialog.getNumber (); //3
	Name = Dialog.getString (); //4
	x0 = Dialog.getNumber (); //5
	y0 = Dialog.getNumber (); //6
	z0 = Dialog.getNumber (); //7
	Radius = Dialog.getNumber (); //5
	OnlySurface=Dialog.getCheckbox (); //check 1
}

setBatchMode(true);

newImage(Name, "8-bit black", Width, Height, Slices);
R = pow(Radius,2);
for (x=0;x<Width;x++) {
	showProgress(x/Width);
	for (y=0;y<Height;y++) {
		for (z=0;z<Slices;z++) {
			if (pow(x-x0,2)+pow(y-y0,2)+pow(z-z0,2) <= R) {
				setSlice(z+1);
				setPixel(x,y,255);
			}	
		}	
	}
}	
if (OnlySurface) {
	run("Duplicate...", "title=Sphere-1 duplicate range=all");
	setOption("BlackBackground", true);
	run("Erode", "stack");
	imageCalculator("Subtract stack", Name,"Sphere-1");
	selectWindow("Sphere-1");
	close();
}

setBatchMode(false);

}