
debuglevel=50;
hostname=getArgument();
////
// radish settings to get relevant info for script.
////
enginesettingsfile="/recon_home/script/dir_radish/engine_"+hostname+"_radish_dependencies";

////
// handle multi-platform troubles
////
// detect windows or mac environmet and modify settings accordingly, 
// detect if we're on zeiss or not.


////
// option vars
////

////
// load instructions for display at top of the dialog box.
////

////
// runnumber var's init
////
minrunnumber=740;
maxrunnumber=760;
runnumdigits=minrunnumber;
runnumberpattern="Z00000";// should get this from a setting file so its relatively easy to expand. 
runnumchars=lengthOf(runnumberpattern);
modality=substring(runnumberpattern,0,1);
modality=toUpperCase(modality);

numzeroes=lengthOf(runnumberpattern)-lengthOf(toString(minrunnumber));

study="James Cook/";
studypath="/mnt/shares/petspace/";


////
// Load files
////
//radish settings
if(File.exists(""+enginesettingsfile))
    {
	enginesettings=File.openAsString(""+enginesettingsfile);	
	enginesettings=split(enginesettings,"\n");
	for(linenum=0;linenum<enginesettings.length;linenum++)
	    {
		line=enginesettings[linenum];
		temp=split(line,"=");
		//engine_work_directory;
		if(startsWith(line,"engine_work_directory")) { engine_work_directory=temp[1]; }
		//engine_recongui_paramfile_directory;
		else if (startsWith(line,"engine_recongui_paramfile_directory")) { engine_recongui_paramfile_directory=temp[1]; } 
		//engine_recongui_menu_path;
		else if (startsWith(line,"engine_recongui_menu_path")) { engine_recongui_menu_path=temp[1]; }
		//engine_archive_tag_directory;
		else if (startsWith(line,"engine_archive_tag_directory")) { engine_archive_tag_directory=temp[1]; }
	    }	
    }
else
    {
	print("ERROR could not find enginesetting file "+enginesettingsfile+"\n");
	run("Quit");
	exit("ERROR could not find enginesetting file "+enginesettingsfile+"\n");


    }
if ( debuglevel >= 45 ) {
    print("engine_recongui_paramfile_directory: "+engine_recongui_paramfile_directory+"\n");
    print("engine_recongui_menu_path:           "+engine_recongui_menu_path+"\n");
    print("engine_work_directory:               "+engine_work_directory+"\n");
    print("engine_archive_tag_directory:        "+engine_archive_tag_directory+"\n");
    }
// Load Vars saved last time
exit;

plugindir=getDirectory("plugins");// probably want the settings directory to be someplace other than there... good dir might be in recon home someplace, 
// /Volumes/recon_home/dir_param_files
//engine_recongui_paramfile_directory=/Volumes/recon_home/dir_param_files

//settingsdir=
persistentvarfilename="create_gui_info_imagej_lastsettings.param"; // last settings param/headfile.
if(File.exists(""+plugindir+"persistentvars/"+persistentvarfilename))
  {
    print("Found Previous vars in file "+plugindir+"persistentvars/"+persistentvarfilename);
    previousvars=File.openAsString(""+plugindir+"persistentvars/"+persistentvarfilename);
    previousvarlines=split(previousvars,"\n");
    ////
    // For loop to pull variables, might be nice to do this based on a var list to make it more general
    ////
    // eg.  foreach (var in varlist )       if(startsWith(previousvarlines[i],var) ) {      temp=split(previousvarlines[i]);        ""+var+""=temp[1];}
    for(i=0;i<previousvarlines.length;i++)
      {
	if(startsWith(previousvarlines[i],"minrunnumber:") )
	  {
	    temp=split(previousvarlines[i]);
	    print(temp[1]);
	    minrunnumber=temp[1];
	  }
	if(startsWith(previousvarlines[i],"study:") )
	  {
	    temp=split(previousvarlines[i]);
	    print(temp[1]);
	    study=temp[1];
	  }
      }
  }

studypath=studypath+"/"+study+"/";
//wait(500);
//parseint on relevent vars just in case
//if(lowmem!=true && lowmem!=false)
//if(lengthOf(minspecid<1))
minspecid=parseInt(minspecid);
//if(lengthOf(maxspecid<1))
maxspecid=parseInt(maxspecid);
//if(lengthOf(specidbase<1))
//if(lengthOf(specidpiece<1))
specidpiece=parseInt(specidpiece);
//if(lengthOf(minrunnumber<1))
minrunnumber=parseInt(minrunnumber);
//if(lengthOf(maxrunnumber<1))
maxrunnumber=parseInt(maxrunnumber);
//if(lengthOf(study<1))



fullminrunnumber=""+modality+"";
while(lengthOf(fullminrunnumber)<numzeroes)	{      fullminrunnumber=fullminrunnumber+"0";	   }
fullminrunnumber=""+fullminrunnumber+""+minrunnumber+"";//next while handles the case where we run out of zeroes, eg we go from a 3digit fullminrunnumber to a 4.
while(lengthOf(fullminrunnumber)!=runnumchars)
  {
    //fullminrunnumber=""+modality+"";
    if(lengthOf(fullminrunnumber)>runnumchars)
      {
	fullminrunnumber=""+modality+"";
	numzeroes--;
      }
    while(lengthOf(fullminrunnumber)<numzeroes)
      {
	fullminrunnumber=fullminrunnumber+"0";
      }
    fullminrunnumber=""+fullminrunnumber+""+minrunnumber+"";
  }
minrunnumber=substring(fullminrunnumber,1);
minrunnumber=parseInt(minrunnumber);
print(fullminrunnumber);

fullmaxrunnumber=""+modality+"";
while(lengthOf(fullmaxrunnumber)<numzeroes)	{      fullmaxrunnumber=fullmaxrunnumber+"0";	   }
fullmaxrunnumber=""+fullmaxrunnumber+""+maxrunnumber+"";//next while handles the case where we run out of zeroes, eg we go from a 3digit fullmaxrunnumber to a 4.
while(lengthOf(fullmaxrunnumber)!=runnumchars)
  {
    //fullmaxrunnumber=""+modality+"";
    if(lengthOf(fullmaxrunnumber)>runnumchars)
      {
	fullmaxrunnumber=""+modality+"";
	numzeroes--;
      }
    while(lengthOf(fullmaxrunnumber)<numzeroes)
      {
	fullmaxrunnumber=fullmaxrunnumber+"0";
      }
    fullmaxrunnumber=""+fullmaxrunnumber+""+maxrunnumber+"";
  }
maxrunnumber=substring(fullmaxrunnumber,1);
maxrunnumber=parseInt(maxrunnumber);
print(fullmaxrunnumber);

fullminspecid=""+specidbase+"-"+minspecid+":"+specidpiece+"";
fullmaxspecid=""+specidbase+"-"+maxspecid+":"+specidpiece+"";
//minspecid=substring(fullminspecid,indexOf(fullminspecid,"-")+1,indexOf(fullminspecid,":"));
//maxspecid=substring(fullmaxspecid,indexOf(fullmaxspecid,"-")+1,indexOf(fullmaxspecid,":"));
print(fullminspecid);
print(fullmaxspecid);

Dialog.create("Open Novartis PET data");
Dialog.addMessage(""+studypath+"");
Dialog.addString("Study Directory:",studypath)
Dialog.addMessage("Enter in the starting and stopping run number below");
Dialog.addString("Start runnumber: ",fullminrunnumber);
Dialog.addString("End runnumber: ",fullmaxrunnumber);
Dialog.addMessage("Enter in the beginning and ending animal id's below");
Dialog.addString("Minspecimenid: ",fullminspecid);
Dialog.addString("Maxspecimenid: ",fullmaxspecid);
Dialog.addCheckbox("inarchive?",isinarchive);
Dialog.addCheckbox("researchdata?",isresearchdata);
Dialog.show();
studypath=Dialog.getString();
fullminrunnumber=Dialog.getString();
minrunnumber=substring(fullminrunnumber,1);
minrunnumber=parseInt(minrunnumber);
fullmaxrunnumber=Dialog.getString();
maxrunnumber=substring(fullmaxrunnumber,1);
maxrunnumber=parseInt(maxrunnumber);
fullminspecid=Dialog.getString();
specidbase=substring(fullminspecid,0,indexOf(fullmaxspecid,"-"));
minspecid=substring(fullminspecid,indexOf(fullminspecid,"-")+1,indexOf(fullminspecid,":"));
fullmaxspecid=Dialog.getString();
maxspecid=substring(fullmaxspecid,indexOf(fullmaxspecid,"-")+1,indexOf(fullmaxspecid,":"));
isinarchive=Dialog.getCheckbox();
isresearchdata=Dialog.getCheckbox();

print(specidbase);
print(minspecid);
print(maxspecid);
print(minrunnumber);
print(maxrunnumber);

/////
// save vars to file here.
////
filename=""+plugindir+"persistentvars/"+persistentvarfilename;
varlist="var1 var2"; //varlist is unused as of yet
varsave(filename, varlist);



////
// Prep runnumber for use
////
runnumber=""+modality+"";
while(lengthOf(runnumber)<numzeroes)	{      runnumber=runnumber+"0";	   }
runnumber=""+runnumber+""+minrunnumber+"";//next while handles the case where we run out of zeroes, eg we go from a 3digit runnumber to a 4.
while(lengthOf(runnumber)!=runnumchars)
  {
    //runnumber=""+modality+"";
    if(lengthOf(runnumber)>runnumchars)
      {
	runnumber=""+modality+"";
	numzeroes--;
      }
    while(lengthOf(runnumber)<numzeroes)
      {
	runnumber=runnumber+"0";
      }
    runnumber=""+runnumber+""+minrunnumber+"";
  }
runnumdigits=substring(runnumber,1);
runnumdigits=parseInt(runnumdigits);



osemiters=0;
images=63;
slicenumcoronal=0;
x=0;
y=0;
lastspecid=0;
lastrunnumdigits=0;
smoothing="";
doseavg=0;
doses=0;

for(go=0; go<4;go++)
  {
    print("=================== GO LOOP ================");
    lastrunnumdigits=0;
    lastspecid=0;

    //	for(smoothing=1;smoothing<5;smoothing++)
    //	{


    //    setBatchMode(true);
    for (specid=minspecid;specid<=maxspecid; specid++)
      {


	////
	// do work on each run number image
	////
	y=0;
	lastrunnumdigits=0;
	row=0;
	for(runnumdigits=minrunnumber; runnumdigits<=maxrunnumber; runnumdigits++)
	  {
	    ////
	    //  build runnumber from digit and modality.
	    ////
	    runnumber=""+modality+"";
	    while(lengthOf(runnumber)<numzeroes)	{      runnumber=runnumber+"0";	   }
	    runnumber=""+runnumber+""+runnumdigits+"";
	    //next while handles the case where we run out of zeroes, eg we go from a 3digit runnumber to a 4.
	    while(lengthOf(runnumber)!=runnumchars)
	      {
		//runnumber=""+modality+"";
		if(lengthOf(runnumber)>runnumchars)
		  {
		    runnumber=""+modality+"";
		    numzeroes--;
		  }
		while(lengthOf(runnumber)<numzeroes)
		  {
		    runnumber=runnumber+"0";
		  }
		runnumber=""+runnumber+""+runnumdigits+"";
	      }
	    errorlevel=0;
	    //imgpath="Datasets/"+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"/";
	    //"+modality+"
	    if(isinarchive==true&&isresearchdata==true)
	      {
		imgpath="research/"+runnumber+"/";
	      }
	    else if (isinarchive==false)
	      {
		imgpath="Datasets/"+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"/";
	      }
	    else if (isinarchive==true && isresearchdata==false)
	      {
		imgpath="/"+runnumber+"/";
	      }

	    ////
	    // work on images based on title.
	    ////
	    if (isOpen(""+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img"))
	      {
		print("Placing window: "+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img");
		selectWindow(""+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img");
		////
		// position window
		////
		getDimensions(width, height, channels, slices, frames);
		xoffset=width+11;
		yoffset=height+62;
		//if runnumberhigher & specidlower
		if(specid>lastspecid && lastspecid!=0)
		  {
		    x=x+xoffset;
		  }
		if(runnumdigits>lastrunnumdigits&&lastrunnumdigits!=0)
		  {
		    y=y+yoffset;
		  }
		//ifspecid=maxspecid reset x
		selectWindow(""+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img");
		setLocation(x,y);
		rename(""+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"");
		lastrunnumdigits=runnumdigits;
		lastspecid=specid;



	      }
	    else if(isOpen(""+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+""))
	      {
		print("Reorienting: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"");
		selectWindow(""+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"");
		getLocationAndSize(x, y, width, height);
		// wait(50);
		run("Select All");
		run("Reslice [/]...", "input=2.000 output=1.000 start=Top");
		setMetadata("Label",runnumber);
		rename(""+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"coronal");
		getDimensions(mywidth, myheight, mychannels, myslices, myframes);
		if(myslices!=1) { slicenumcoronal=myslices/2; } else {slicenumcoronal=myslices}
		setSlice(slicenumcoronal);
		setLocation(x,y);
		if(doseavg>1){ doseavg=doseavg/doses;}
		//print("Doseaverage="+doseavg+"");
		//run("Divide...", "stack value="+dose+"");
		//setMinAndMax(0.95, 1.15);
		//setMinAndMax(1046491776.0000, 1098687488.0000);
		//makeoval(4, 22, 28, 23);
		//makeOval(68, 64, 11, 8);
		//print(""+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"coronal");
		//run("Summarize");
		//run("Histogram", "bins=256 use x_min=578657536 x_max=1112395392 y_max=Auto stack");
		selectWindow(""+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"");
		close();
	      }
	    else if (isOpen(""+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"coronal") )
	      {
		////
		// open hdrfile and parse important information
		////
		hdrcontents=File.openAsString(""+studypath+""+imgpath+""+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img.hdr");
		//print(""+studypath+""+imgpath+""+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img.hdr");
		hdrlines=split(hdrcontents,"\n");
		//hdrlength=lengthOf(hdrlines);
		//print("hdrlength is "+hdrlength+"");
		////
		for(i=0;i<hdrlines.length;i++)
		  {
		    // for line in lines
		    ////
		    // check dose units
		    ////
		    //        dose=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep "dose_units" | cut -d" " -f 2`
		    if(startsWith(hdrlines[i],"dose_units") )
		      {

			temp=split(hdrlines[i]);
			dose_units=temp[1];
		      }
		    ////
		    // check dose
		    ////
		    //        dose=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep dose | grep -v "dose_units" | cut -d" " -f 2`
		    else if (startsWith(hdrlines[i],"dose") )
		      {
			//    if line startswith dose
			temp=split(hdrlines[i]);
			dose=temp[1];
		      }
		    ////
		    // check weight units
		    ////
		    //        weight=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep subject_weight | grep -v "subject_weight_units" | cut -d" " -f 2`
		    else if(startsWith(hdrlines[i],"subject_weight_units") )
		      {
			//    if line startswith subject_weight_units
			temp=split(hdrlines[i]);
			subject_weight_units=temp[1];
		      }
		    ////
		    // check weight
		    ////
		    //        weight=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep subject_weight | grep -v "subject_weight_units" | cut -d" " -f 2`
		    else if(startsWith(hdrlines[i],"subject_weight") )
		      {
			//    if line startswith subject_weight
			temp=split(hdrlines[i]);
			subject_weight=temp[1];
		      }
		    ////
		    // check study_identifier
		    ////
		    //study_identifier 09-novartis-01
		    else if(startsWith(hdrlines[i],"study_identifier") )
		      {

			temp=split(hdrlines[i]);
			study_identifier=temp[1];
		      }
		    ////
		    // check subject_identifier
		    ////
		    // subject_identifier
		    else if(startsWith(hdrlines[i],"subject_identifier") )
		      {

			temp=split(hdrlines[i]);
			subject_identifier=temp[1];
		      }

		    ////
		    // check acq_mode
		    ////
		    //        acq_mode=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep acquisition_mode | cut -d" " -f 2`
		    else if(startsWith(hdrlines[i],"acquisition_mode") )
		      {

			temp=split(hdrlines[i]);
			acq_mode=temp[1];
		      }
		    ////
		    // check file_type
		    ////
		    //        file_type=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep file_type | cut -d" " -f 2`
		    else if(startsWith(hdrlines[i],"file_type") )
		      {

			temp=split(hdrlines[i]);
			file_type=temp[1];
		      }
		    ////
		    // check isotope
		    ////
		    //        isotope=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep -E "^isotope +" | cut -d" " -f 2`
		    else if(startsWith(hdrlines[i],"isotope_half_life") )
		      {
			//donothing
		      }
		    else if(startsWith(hdrlines[i],"isotope_branching_fraction") )
		      {
			//donothing
		      }
		    else if(startsWith(hdrlines[i],"isotope") )
		      {

			temp=split(hdrlines[i]);
			isotope=temp[1];
		      }
		    ////
		    // check span
		    ////
		    //        span=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep span | cut -d" " -f 2`
		    else if(startsWith(hdrlines[i],"span") )
		      {

			temp=split(hdrlines[i]);
			span=temp[1];
		      }
		    ////
		    // check ring_difference
		    ////
		    //        ring_diff=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep ring_difference | cut -d" " -f 2`
		    else if(startsWith(hdrlines[i],"ring_difference") )
		      {
			temp=split(hdrlines[i]);
			ring_difference=temp[1];
		      }
		    ////
		    // check recon_algorithm
		    ////
		    //        recon_algorithm=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep recon_algorithm | cut -d" " -f 2`
		    else if(startsWith(hdrlines[i],"recon_algorithm") )
		      {
			temp=split(hdrlines[i]);
			recon_algorithm=temp[1];
		      }
		    ////
		    // check map_iterations
		    ////
		    //        map_iterations=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep map_iterations | cut -d" " -f 2`
		    else if(startsWith(hdrlines[i],"map_iterations") )
		      {
			temp=split(hdrlines[i]);
			map_iterations=temp[1];
		      }
		    ////
		    // check map_osem3d_iterations
		    ////
		    //        map_osem3d_iterations=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep map_osem3d_iterations | cut -d" " -f 2`
		    else if(startsWith(hdrlines[i],"map_osem3d_iterations") )
		      {
			temp=split(hdrlines[i]);
			map_osem3d_iterations=temp[1];
		      }
		    ////
		    // check deadtime_correction
		    ////
		    //        deadtime_correction=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep deadtime_correction_applied | cut -d" " -f 2`
		    else if(startsWith(hdrlines[i],"deadtime_correction_applied") )
		      {
			temp=split(hdrlines[i]);
			deadtime_correction=temp[1];
		      }
		    ////
		    // check decay_correction
		    ////
		    //        decay_correction=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep decay_correction_applied | cut -d" " -f 2`
		    else if(startsWith(hdrlines[i],"decay_correction_applied") )
		      {
			temp=split(hdrlines[i]);
			decay_correction=temp[1];
		      }
		    ////
		    // check normalization
		    ////
		    //        normalization=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep normalization_applied | cut -d" " -f 2`
		    else if(startsWith(hdrlines[i],"normalization_applied") )
		      {
			temp=split(hdrlines[i]);
			normalization=temp[1];
		      }
		    ////
		    // check attenuation
		    ////
		    //        attenuation=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep attenuation_applied | cut -d" " -f 2`
		    else if(startsWith(hdrlines[i],"attenuation_applied") )
		      {
			temp=split(hdrlines[i]);
			attenuation=temp[1];
		      }
		    ////
		    // check scatter
		    ////
		    //        scatter=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep scatter_correction | cut -d" " -f 2`
		    else if(startsWith(hdrlines[i],"scatter_correction") )
		      {
			temp=split(hdrlines[i]);
			scatter_correction=temp[1];
		      }
		    ////
		    // check arc_correction
		    ////
		    //        arc_correction=`cat $dirtocheck"/"$folder"/"$file | grep -v "#" | grep arc_correction_applied | cut -d" " -f 2`
		    else if(startsWith(hdrlines[i],"arc_correction_applied") )
		      {

			temp=split(hdrlines[i]);
			arc_correction=temp[1];
		      }

		    ////
		    // check tempalte
		    ////
		    //		    else if (startsWith(hdrlines[i],"template") )
		    //		      {
		    //			//    if line startswith template
		    //			temp=split(hdrlines[i]);
		    //			template=temp[1];
		    //		      }
		  }
		// End of hdr file info extraction,

		////
		// Check values extracted from the header.
		////
		if (dose<0.05 || dose>0.6)
		  {
		    //		    dose=""+dose+" Dose Value Error";
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+" Dose Value Error");
		  }
		else {
		  // make dose average to multiply by.

		  doseavg=parseFloat(dose)+parseFloat(doseavg);
		  doses++;
		}
		if (dose_units!=1)
		  {
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+" Dose Units Error");
		  }
		if (subject_weight>40 || subject_weight<15)
		  {
		    //		    subject_weight=""+subject_weight+" Subject_Weight Value Error";
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+" Weight Error");
		  }
		if (subject_weight_units!=1)
		  {
		    //		    subject_weight=""+subject_weight+" g";
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+" Weight Units Error");
		  }
		if(study_identifier!="09-novartis-04" && study_identifier!="09.novartis.04" &&study_identifier!="09-novartis-03" && study_identifier!="09.novartis.03")
		  {
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+" Study Identifier Error found "+study_identifier+"");
		  }
		if(subject_identifier!=specidbase+"-"+specid+":"+specidpiece)
		  {
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+" Subject Identifier Error found "+subject_identifier+"");
		  }
		if (acq_mode!=2)
		  {
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+" Acquisition Mode Error");
		  }
		if(file_type!=5)
		  {
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"  Error");
		  }
		if(isotope!="F-18")
		  {
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"  Isotope Error Found"+isotope+"");
		  }
		if(span!=3)
		  {
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"  span Error");
		  }
		if(ring_difference!=31)
		  {
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"  ring_Difference Error");
		  }
		if(map_iterations!=30)
		  {
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"  Map iterations Error");
		  }
		if(map_osem3d_iterations!=0)
		  {
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"  Osem3d Iterations Error");
		  }
		if(deadtime_correction!=1)
		  {
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+" Deadtime Correction Error");
		  }
		if(decay_correction!=1)
		  {
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+" Decay Correction Error");
		  }
		if(normalization!=2)
		  {
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+" Normalization Error");
		  }
		if(attenuation!=1)
		  {
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+" Attenuation Error");
		  }
		if(scatter_correction==23)
		  {
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+" Scatter Correction Error");
		  }
		if(arc_correction!=1)
		  {
		    run("Red");
		    run("Invert LUT");
		    errorlevel++;
		    print("ERROR: "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+" Arc Correction Error");
		  }

		////
		// Put values and error check info into results
		////
		//setResult("Column",row, value);
		setResult("Label", row, "Dose mCi");
		setResult(""+specidbase+"-"+specid+":"+specidpiece+"", row, dose);
		setResult(""+specidbase+"-"+specid+":"+specidpiece+" Dose Units", row, dose_units);
		row++;
		setResult("Label", row, "weight g");
		setResult(""+specidbase+"-"+specid+":"+specidpiece+"", row, subject_weight);
		setResult(""+specidbase+"-"+specid+":"+specidpiece+" Weight Units", row, subject_weight_units);
		print("Header parsed "+studypath+""+imgpath+""+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img.hdr Dose: "+dose+" Weight: "+subject_weight+"");
		updateResults();
		row++;
		if (dose<0.05 || dose>0.6)
		  {
		    selectWindow(""+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"coronal");
		    //selectWindow(""+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img");
		  }
		else
		  {
		    dosevar=(parseFloat(dose)*1000000);
		    //run("Divide...", "stack value="+dosevar+"");
		  }
		selectWindow(""+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"coronal");
		if(errorlevel==0)
		  {
		    run("Grays");
		    if(is("Inverting LUT"))
		      {
			run("Invert LUT");
		      }
		  }

		//		selectWindow(""+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img");
		getMinAndMax(min,max);
		//		if(max>20 )
		//		  {
		//		    run("Divide...", "stack value=1000000000");
		//		    setMinAndMax(0.95, 1.15); //		setMinAndMax(1046491776.0000, 1098687488.0000);
		//		  }
		//		if(max<0.1)
		//		  {
		//		    run("Multiply...", "stack value=1000000000");
		//		  }
		////
		// check dimensions
		////
		selectWindow(""+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"coronal");
		getDimensions(mywidth, myheight, mychannels, myslices, myframes);
		if(mywidth<128 || myheight<63 || myslices<128) {
		  print("Expected dimensions not found: error ");
		  if(mywidth<128) {print("width error "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+""); }
		  if(myheight<63) {print("slice error "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+""); }
		  if(myslices<128) {print("height error "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+""); }
		}
		else
		  {
		    //		    print("Dimensions check out for "+specidbase+"-"+specid+":"+specidpiece+" "+runnumber+"");
		  }
		//rename(""+specid+"_"+runnumdigits+"");
	      }
	    else if(isOpen("smoothing_"+smoothing+"osem3d_"+runnumber+"map_"+specid+""))
	      {
		selectWindow("smoothing_"+smoothing+"osem3d_"+runnumber+"map_"+specid+"");
		rename(""+smoothing+"_"+runnumber+"_"+specid+"");
	      }
	    else if (isOpen(""+specid+"_"+runnumdigits+"") )
	      {
		selectWindow(""+specid+"_"+runnumdigits+"");
		rename(""+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img");

	      }
	    else
	      {
		//print("/Volumes/atlas1/09.novartis.03/research/"+runnumber+"/"+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img");
		//if(File.exists("/Volumes/atlas1/09.novartis.03/research/"+runnumber+"/"+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img"))
		if(go==0)
		  print("Looking for file: "+studypath+""+imgpath+""+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img");
		if(File.exists(""+studypath+""+imgpath+""+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img"))
		  {
		    //imgpath="research/"+runnumber+"/";
		    print("opening raw: "+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img");
		    run("Raw...", "open="+studypath+""+imgpath+""+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img image=[32-bit Real] width=128 height=128 offset=0 number=63 gap=0 little-endian");
		    setMetadata("Label",runnumber);

		    //run("Raw...", "open=/Volumes/atlas1/09.novartis.03/research/"+runnumber+"/"+specidbase+"_"+specid+"_"+specidpiece+"_"+runnumber+"_v1.img image=[32-bit Signed] width=128 height=128 offset=0 number=63 gap=0 little-endian");
		  }
		else 
		  {
		    if(go==0)
		      print(" File not found");
		}
	      }

	  }
	runnumdigits=substring(runnumber,1);
	runnumdigits=parseInt(runnumdigits);
      }
    y=0;
  } //if open process... else who cares.

wait(100);
//setBatchMode("exit and display");
//setBatchMode(false);

exit;


function varsave(filenamepath,mylist)
{
  requires("1.41f");
  /////
  // save vars to file here.
  ////

  //varpersistencefile=File.open(""+plugindir+"persistentvars/PET_Novartis_Analysis_VARS.txt");
  varpersistencefile=File.open(filenamepath);
  //generic idea
  //  for(i=list.size(mylist),i>=0,i--) //for file in list
  //{
  //  print(varpersistencefile, lise.get(  );
  //}
  //  print(varpersistencefile, "lowmem: "+lowmem );
  print(varpersistencefile, "minspecid: "+minspecid);
  print(varpersistencefile, "maxspecid: "+maxspecid);
  print(varpersistencefile, "specidbase: "+specidbase);
  print(varpersistencefile, "specidpiece: "+specidpiece);
  print(varpersistencefile, "minrunnumber: "+minrunnumber);
  print(varpersistencefile, "maxrunnumber: "+maxrunnumber);
  //  print(varpersistencefile, "useoldroi: "+useoldroi);
  study=File.getName(studypath);
  print(study);
  print(varpersistencefile, "study: "+study);

  //maxspecid=substring(fullmaxspecid,indexOf(fullmaxspecid,"-")+1,indexOf(fullmaxspecid,":"));
  //studypath=substring(studypath,0,indexOf(studypath,study));
  i1=0;
  i2=indexOf(studypath,study);
  temp=substring(""+studypath+"",i1,i2);
  studypath=temp;

  print(studypath);
  print(varpersistencefile, "studypath: "+studypath);
  
  File.close(varpersistencefile);
  return 1;

  //List Functions;
  //These functions work with a list of key/value pairs. The ListDemo macro demonstrates how to use them. Requires 1.41f.;
  //List.set(key, value) - Adds a key/value pair to the list.;
  //List.get(key) - Returns the string value associated with key, or an empty string if the key is not found. ;
  //List.getValue(key) - When used in an assignment statement, returns the value associated with key as a number. Aborts the macro if the value is not a number or the key is not found. Requires v1.42i.;
  //List.size - Returns the size of the list.;
  //List.clear() - Resets the list.;
  //List.setList(list) - Loads the key/value pairs in the string list.;
  //List.getList - Returns the list as a string.;
  //List.setMeasurements - Measures the current image or selection and loads the resulting parameter names (as keys) and values. All parameters listed in the Analyze>Set Measurements dialog box are measured. Use List.getValue() in an assignment statement to retrieve the values. See the DrawEllipse macro for an example. Requires v1.42i.;
  //List.setCommands - Loads the ImageJ menu commands (as keys) and the plugins that implement them (as values). Requires v1.43f. ;
}
