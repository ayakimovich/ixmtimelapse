//============================================================
//
// ImageJ Macro to create timelapse movies from single IXM timelapse images
//    (c)2011-2016 Artur Yakimovich, University of Zurich 
//============================================================
macro "ixmtimelapse" {
	 //functions definition

	 function getTimePointList(ReadPath){
	 	list = getFileList(ReadPath);
		Array.print(list);
		//clean up the file list
		dirList = newArray();
		timePointsList = newArray();

		for(i=0; i<=list.length-1; i++){
		   //if (endsWith(list[i], "/"))
		   //              dirList = Array.concat(dirList, list[i]);
		   if (startsWith(list[i], "TimePoint_")){
		   	  iTP = iTP + 1;
		      timePointsList = Array.concat(timePointsList, "TimePoint_"+iTP);
		      }
			  else
			  print("pre-processing: pattern not found");
						//exit();
		}
		//Array.sort(timePointsList);
		Array.print(timePointsList);	
	 	return timePointsList;
	 }

	 function getDirAndFileList(ReadPath, filePattern, listType){
	 	//listType = "dir" or "file", file default
	 	list = getFileList(ReadPath);
		//clean up the file list
		dirList = newArray();
		fileList = newArray();
		
		for(i=0; i<=list.length-1; i++){
			if (endsWith(list[i], "/"))
				dirList = Array.concat(dirList, list[i]);
			else if (matches(list[i], filePattern))
				fileList = Array.concat(fileList, list[i]);
		}
		if (listType == "dir"){
			return dirList;	
		}
		else if (listType == "file"){
			return fileList;
		}
		else {
			return fileList;
		}
	}
	 	 

	 
	 function getCheckboxValues(){
	 	RowLetterArray = newArray();
		for (i=0; i<=labels.length-1; i++){
	  		row = Dialog.getCheckbox();
	  		if (row == 1){
	  			RowLetterArray = Array.concat(RowLetterArray, labels[i]);
	  		}
		}
		return RowLetterArray;
	 }
	 function images2stacks(rowList, minCol, maxCol, minSite, maxSite, minW, maxW, ReadPath, processedDir) {

		//wavelength = "B02_s1_w1.TIF";

		timePointsList = getTimePointList(ReadPath);
		iTP = 0;
		
		//exit()
		fileList = getFileList(ReadPath+File.separator+timePointsList[0]);
		Array.print(fileList);
		for (iSite = minSite; iSite <= maxSite; iSite++){
			for (iRow = 0; iRow <= rowList.length-1; iRow++){	
				for (iCol = minCol; iCol <= maxCol; iCol++){
					for (iW = minW; iW <= maxW; iW++){
		
						if (iCol < 10){
							pattern = rowList[iRow]+"0"+iCol+"_s"+iSite+"_w"+iW+".TIF";
							}
						else {
							pattern = rowList[iRow]+iCol+"_s"+iSite+"_w"+iW+".TIF";
							}
						
						print("pre-processing: "+pattern);
						//exit();
						imageList = newArray();
						for(i=0; i<=fileList.length-1; i++){
						                if (endsWith(fileList[i], pattern))
						                   imageList = Array.concat(imageList, fileList[i]);
						                else
						                   print ("pre-processing: pattern not found in "+fileList[i]);
						}
					//main for-loop
					
					Array.print(imageList);
					//exit();
					
					
					for(i=0; i<=imageList.length-1; i++){
					   print (imageList[i]);
					                
					   //open an image from the list
					   for(j=0; j<=timePointsList.length-1; j++){
					       print("pre-processing: time point "+timePointsList[j]);
					       open(ReadPath+File.separator+timePointsList[j]+File.separator+imageList[i]);
					   }                
					   run("Images to Stack", "name="+imageList[i]);
					
					   // get the title and save the image
					   //title = getTitle();
					   print("pre-processing: Saving "+imageList[i]);
					   saveAs("Tiff", processedDir+File.separator+replace(imageList[i],".tif","_movie.tif"));
					   //close the window
					   close();
					   }
					}
				}
			}
		}
		print ("end preprocessing");
      
    }
	function stacks2rgb(filePattern, patternRed, minRed, maxRed, preprocess, patternGreen, minGreen, maxGreen, patternBlue, minBlue, maxBlue, ReadPath, grayFlag, patternGray, minGray, maxGray, processedDir){


	

		dirList = getDirAndFileList(ReadPath, filePattern, "dir")
		fileList = getDirAndFileList(ReadPath, filePattern, "file")
		//main for-loop
		
		print(fileList.length);
		print ("start");
		
		for(i=0; i<=fileList.length-1; i++){
		
			print (fileList[i]);
			//open an images from the list according from the respective channel
		    //red are 4000 and 18000; for green 3500 and 28000; for blue 700 and 2500
			// red
			redFileName = replace(fileList[i], "w1", patternRed);
			print(ReadPath+redFileName);
			open(ReadPath+redFileName);
			
			if(preprocess == true){
				print("preprocessing...");
				run("Enhance Contrast", "saturated=0.35");
				run("Subtract Background...", "rolling=50 stack");
			}
			setMinAndMax(minRed, maxRed);
		    run("8-bit");
		    
			// green
			greenFileName = replace(fileList[i], "w1", patternGreen);
			open(ReadPath+greenFileName);
			if(preprocess == true){
				run("Enhance Contrast", "saturated=0.35");
				run("Subtract Background...", "rolling=50 stack");
			}
			setMinAndMax(minGreen, maxGreen);
		    run("8-bit");
		    
			// blue
			blueFileName = replace(fileList[i], "w1", patternBlue);
			open(ReadPath+blueFileName);
			if(preprocess == true){
				run("Enhance Contrast", "saturated=0.35");
				run("Subtract Background...", "rolling=50 stack");
			}
			setMinAndMax(minBlue, maxBlue);
		    run("8-bit");
			if(grayFlag == true){		
				grayFileName = replace(fileList[i], "w1", patternGray);
				open(ReadPath+grayFileName);
				if(preprocess == true){
					run("Enhance Contrast", "saturated=0.35");
				}
				setMinAndMax(minGray, maxGray);
		    	run("8-bit");
		   		run("Merge Channels...", "c1="+redFileName+" c2="+greenFileName+" c3="+blueFileName+" c4="+grayFileName+"");
			}
			else{
				run("Merge Channels...", "c1="+redFileName+" c2="+greenFileName+" c3="+blueFileName);
			}

		    run("RGB Color", "slices keep");
		    newFileName = replace(fileList[i], "w1", "merge");
			print(newFileName);
		    saveAs("Tiff", processedDir +File.separator+ newFileName);
			run("Close All");
		
		}
		print(processedDir+" saving RGB finished succesfully");
	}
	
	//creating GUI
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	guiSpacer = "\n ";
	guiSeparator = "\n__________________________________________________\n "
	version = "\n                                               v0.2. MIT license."
	copyrightMessage = "                                 ImageXpress Micro Timelapse \n                        (copyright) Artur Yakimovich 2011-"+year
	html = "<html>"
     +"<h2>ImageXpress Micro Timelapse About</h2>"
     +"<font size=+1>"
     +"Please visit <a href='https://github.com/ayakimovich/ixmtimelapse'>https://github.com/ayakimovich/ixmtimelapse</a> For the up-to-date version, help or contributing<br><br>"
     +"Copyright &copy; Artur Yakimovich 2011-"+year+"</font>"
     +"</html>";
	// draw parameters 1
	Dialog.create("ImageXpress Micro Timelapse - setup step 1 of 3");
		Dialog.addMessage(copyrightMessage+version+guiSeparator);
		Dialog.addHelp(html);
		Dialog.addMessage("1. Set up general Parameters:");
		Dialog.addCheckbox("1a. Pre-process to create multi-layer TIF-files (step 2)", true);		
		Dialog.addCheckbox("1b. Merge and save RGB TIF stacks (step 3)", true);
		Dialog.addCheckbox("   1c. Would you like to use transmission light channel? (step 3)", true);
		Dialog.addMessage(guiSeparator);
	Dialog.show();
	//retrieving parameters 1.
	step2Flag = Dialog.getCheckbox();
	step3Flag = Dialog.getCheckbox();
	grayFlag = Dialog.getCheckbox();
	//2.	
	if (step2Flag == true){
		// draw parameters 3
		Dialog.create("ImageXpress Micro Timelapse - setup step 2 of 3");
			Dialog.addMessage(copyrightMessage+version+guiSeparator);
			Dialog.addHelp(html);
			Dialog.addNumber("2a. First Wavelength:", 1);
			Dialog.addNumber("2b. Last Wavelength:", 2);
			Dialog.addNumber("2c. First Plate Column:", 1);
			Dialog.addNumber("2d. Last Plate Column:", 12);
			Dialog.addString("2e. Image File Extension:", ".TIF");
			Dialog.addMessage("2f. Select rows in your plate:");
			labels = newArray("A", "B", "C", "D", "E", "F", "G", "H");
			defaults = newArray(true,true,true,true,true,true,true,true);
			Dialog.addCheckboxGroup(1,8,labels,defaults);
			Dialog.addString("2g. Folder Name:", "16bit_Movies");	
			Dialog.addNumber("2h. First Site:", 1);
			Dialog.addNumber("2i. Last Site:", 9);
			Dialog.addMessage(guiSeparator);
		Dialog.show();
		//retrieving parameters 2.	
		firstWavelength=Dialog.getNumber();
		lastWavelength=Dialog.getNumber();
		firstPlateColumn = Dialog.getNumber();
		lastPlateColumn = Dialog.getNumber();
		extension = Dialog.getString();
		RowLetterArray = getCheckboxValues();
		preprocessFolderName = Dialog.getString();
		firstSite = Dialog.getNumber();
		lastSite = Dialog.getNumber();
	}
	//3.
	if (step3Flag == true){
		// draw parameters 3
		Dialog.create("ImageXpress Micro Timelapse - setup step 3 of 3");
			Dialog.addMessage(copyrightMessage+version+guiSeparator);
			Dialog.addHelp(html);
			Dialog.addMessage("3. Merge Channels:");
			Dialog.addString("3a. File name pattern:", "^.*_[A-H][0-9]*_s[0-9]_w1.*.tif")
			Dialog.addString("3b. Save Folder Name:", "RGB_Movies")
			Dialog.addString("3c. Red name pattern:", "w1");
			Dialog.addSlider("3d. Min Red:", 0, 65535, 150);
			Dialog.addSlider("3e. Max Red:", 0, 65535, 1800);
			Dialog.addString("3f. Green name pattern:", "w2");
			Dialog.addSlider("3g. Min Green:", 0, 65535, 150);
			Dialog.addSlider("3h. Max Green:", 0, 65535, 1800);
			Dialog.addString("3i. Blue name pattern:", "w3");
			Dialog.addSlider("3j. Min Green:", 0, 65535, 50);
			Dialog.addSlider("3k. Max Green:", 0, 65535, 300);
			
			if(grayFlag == true){
				Dialog.addString("3l. Gray name pattern:", "w4");
				Dialog.addSlider("3m. Min Green:", 0, 65535, 1200);
				Dialog.addSlider("3n. Max Green:", 0, 65535, 6000);
				Dialog.addCheckbox("3o. Gray-scale pre-processing", true);
			}
			Dialog.addMessage(guiSeparator);
		Dialog.show();

		//retrieving parameters 3.	
		filePattern = Dialog.getString();
		saveFolderName = Dialog.getString();
		patternRed = Dialog.getString();
		minRed = Dialog.getNumber();
		maxRed = Dialog.getNumber();
		patternGreen = Dialog.getString();
		minGreen = Dialog.getNumber();
		maxGreen = Dialog.getNumber();
		patternBlue = Dialog.getString();
		minBlue = Dialog.getNumber();
		maxBlue = Dialog.getNumber();
		if(grayFlag == true){
			patternGray = Dialog.getString();
			minGray = Dialog.getNumber();
			maxGray = Dialog.getNumber();
			preprocess = Dialog.getCheckbox();
		}
		else{
			patternGray = "";
			minGray = 0;
			maxGray = 0;
			preprocess = false;
		}
	}
	if(step3Flag == false && step2Flag == false){
		print("no processing selected. exiting...");
		exit(0);
	}
	else{
		ReadPath = getDirectory("Choose a Directory");
	  
		setBatchMode(true);
		//save parameters to a text file
		f = File.open(ReadPath+"timelapse_parameters.txt");
			rowLetterArrayPrint = "";
			for (i = 0; i <= RowLetterArray.length-1; i++){
					rowLetterArrayPrint = rowLetterArrayPrint + RowLetterArray[i] + ", ";
				}
			step1Parameters = "\n\t RowLetterArray:"+rowLetterArrayPrint+"\n\t firstPlateColumn:"+d2s(firstPlateColumn,0)+"\n\t lastPlateColumn:"+d2s(lastPlateColumn,0)+"\n\t firstSite:"+d2s(firstSite,0)+"\n\t lastSite:"+d2s(lastSite,0)+"\n\t firstWavelength:"+d2s(firstWavelength,0)+"\n\t lastWavelength:"+d2s(lastWavelength,0)+"\n\t ReadPath:"+ReadPath+"\n\t processedDir:"+preprocessFolderName;
			step2Parameters = "\n\t filePattern:"+filePattern+"\n\t patternRed:"+d2s(patternRed,0)+"\n\t minRed:"+d2s(minRed,0)+"\n\t maxRed:"+d2s(maxRed,0)+"\n\t preprocess:"+preprocess+"\n\t patternGreen:"+d2s(patternGreen,0)+"\n\t minGreen:"+d2s(minGreen,0)+"\n\t maxGreen:"+d2s(maxGreen,0)+"\n\t patternBlue:"+patternBlue+"\n\t minBlue:"+d2s(minBlue,0)+"\n\t maxBlue:"+d2s(maxBlue,0)+"\n\t ReadPath:"+ReadPath+"\n\t grayFlag:"+grayFlag+"\n\t patternGray:"+patternGray+"\n\t minGray:"+d2s(minGray,0)+"\n\t maxGray:"+d2s(maxGray,0)+"\n\t saveDir:"+saveFolderName;
			print(f,"Step 1 Parameeters: \n"+step1Parameters+"Step 2 Parameeters: \n"+step2Parameters);
		File.close(f)
		//running processings
		
		//2.
		if (step2Flag == true){
			//preprocessing dir:
			processedDir=ReadPath+preprocessFolderName;
			File.makeDirectory(processedDir);
			images2stacks(RowLetterArray, firstPlateColumn, lastPlateColumn, firstSite, lastSite, firstWavelength, lastWavelength, ReadPath, processedDir);
		}
	
		//3.
		if (step3Flag == true){
		//finnal movies dir
			saveDir=ReadPath+saveFolderName;
			File.makeDirectory(saveDir);
				stacks2rgb(filePattern, patternRed, minRed, maxRed, preprocess, patternGreen, minGreen, maxGreen, patternBlue, minBlue, maxBlue, ReadPath, grayFlag, patternGray, minGray, maxGray, saveDir);
			}
		setBatchMode(false);
		}
	}
}