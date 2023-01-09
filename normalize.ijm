/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input image directory", style = "directory") input
#@ File (label = "Output image directory", style = "directory") output

#@ String (label = "File suffix", value = ".tif") suffix


// See also Process_Folder.py for a version of this code
// in the Python scripting language.

processFolder(input);                     

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input); 
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	
	print("Processing: " + input + File.separator + file);
	open( input + File.separator + file );
	run("Enhance Contrast...", "saturated=0.3 process_all use");
	run("8-bit");
	run("8-bit");
	/*run("Size...", "width="+newWidth+" height="+newHeight+" depth="+slices+" constrain average interpolation=Bilinear");
	*/
	print("Saving to: " + output + File.separator + file);
	save(output + File.separator + file);
	close();
	/*selectWindow("Composite-1");
	close();*/
	/*open( inputDirLabels + File.separator + file );
	run("Size...", "width="+newWidth+" height="+newHeight+" depth="+slices+" constrain interpolation=None");
	print("Saving to: " + outputDirLabels + File.separator + file);
	save(outputDirLabels + File.separator + file);
	close();*/
	//run("Make Binary");
}
