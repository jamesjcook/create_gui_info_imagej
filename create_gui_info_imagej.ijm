////////////////////////////////////////////////////////////////////////////////
// Create_gui_info_imagej 
// Planed to be a feature compatabile drop in replacement for the 
// create_gui_info tcl  gui for radish
// Imagej chosen for cross platform compatabiltiy, and minimal install size
// 
// should emulate create_gui_info as completely as possible. hopefully down to 
// bug compatability
//   
// sally's recon_interface echos everything back to the console to pass its 
// input to perl, this is how this script should operate when called the same 
// way as hers... well shit. 
// what i've made here is too smart, it should only take the recon_menu and 
// the scanner_tesla, optionally it should take a paramfilename in which we will 
// save stuff, 
//
// TRICKS AND LIES!, sally calls recon_interface.tcl directly from 2 places, 
// radish.perl! and create_paramfile.perl!
////////////////////////////////////////////////////////////////////////////////

debuglevel=50;
// expects 3 arguments in order, hostname scanner paramfile 
arglist=getArgument();
arglist=split(arglist," ");
hostname=arglist[0];
if(lengthOf(arglist)>1) {
    scanner=arglist[1];
    if(lengthOf(arglist)>=3) { previous_`param_file_name=arglist[2]; }
    else { previous_param_file_name="create_gui_info_imagej_lastsettings_"+scanner+".param"; }
    //previous_param_file_name="create_gui_info_imagej_lastsettings"+scanner+".param"; // last settings param/headfile.
}
if(debuglevel>=70) {
    print("scanner:         "+scanner);
    print("param_file_name: "+param_file_name);
}
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
		else { 
		    if ( debuglevel >= 70 ) { print(""+line); }
		}
	    }	
    } else {
	exit("ERROR could not find enginesetting file "+enginesettingsfile);
    }
print ("");
if ( debuglevel >= 45 ) {
    print("engine_recongui_paramfile_directory: "+engine_recongui_paramfile_directory);
    print("engine_recongui_menu_path:           "+engine_recongui_menu_path);
    print("engine_work_directory:               "+engine_work_directory);
    print("engine_archive_tag_directory:        "+engine_archive_tag_directory);
    }
//recon_menu.txt
reconmenucomments="";
menuliststring="";        // semi-colon seperated string for each menuname type.
// these arrays cant be set until we know how many menunames we have, we find that out once we read ALLMENUTYPES
menulistelementsarray=""; // array of semi-colon seperated strings, one array element per menuname item
menuvalarray="";          // array of strings, the previous and curretn selected values for each menutname item
specidpattern="[0-9]{6}-[0-9]*:[0-9]*";
specid="000000-1:0";
xmit=0;
optional="";
largestvariablenamelength=0;//setting to be used latter to make display pretty
if(File.exists(""+engine_recongui_menu_path)) {
    reconmenu=File.openAsString(""+engine_recongui_menu_path);
    reconmenu=split(reconmenu,"\n");
    //// need too think more about how to parse this....
    // something like, while line is not a comment, 
    // when line startw with allmenutypes, 
    // for each menu type....
    // build an array of strings... to split up later. 
    // complicated... 
    linenum=0;
    do {
	line=reconmenu[linenum];
	// line should be split taking the first item as the value the second as the scanner list.
	// menuvalue; 
	// scannerlist; 
	if (startsWith(line,"#")) { reconmenucomments=""+reconmenucomments+"\n"+line; if (debuglevel>=85 ) { print("commentline:"+line); } } 
	else if (matches(line,".*TYPE.*")){ 
	    //	    print ("typematch");
	    if(startsWith(line,"ALLMENUTYPES")) { 
		temparray=split(line, ";");
		for(i=1;i<lengthOf(temparray);i++) {
		    varlength=lengthOf(temparray[i]);
		    if(largestvariablenamelength<varlength) { largestvariablenamelength=varlength; }
		    menuliststring=""+menuliststring+toString(i-1)+temparray[i]+";";
		}
		menulistarray=split(menuliststring,";");
		menulistelementsarray=newArray(i); //
		menuvalarray=newArray(i);          // 
		for(i=0;i<lengthOf(menuvalarray);i++) { menuvalarray[i]=""; }
		print("all expected menu items: "+menuliststring);
	    } else {
		if (matches(line,"MENUTYPE;[a-zA-Z0-9_]*")) {
		    menuname=substring(line,indexOf(line,";")+1);
		    if (debuglevel >=65 ) { print("Loading recon menu txt Menu section:"+menuname); }
		} else {
		    exit("found *TYPE* entry but couldnt pull out menu name for linenumber:"+linenum+" in recon menu txt file "+engine_recongui_menu_path+"\n    <"+line+">");
		}
	    } 
	} else {
	    if(indexOf(line,";")>=0) {
		menuval=substring(line,0,indexOf(line,";"));
		scannerlist=substring(line,indexOf(line,";")+1);
		if(matches(scannerlist,".*"+scanner+".*"))
		    { // if our scanner is in the list of valid scanners for this option add
			menuliststringpos=indexOf(menuliststring,menuname)-1;
			if (menuliststringpos <= -1 ) { exit("could not find menuname: <"+menuname+"> in list of all menunames: "+menuliststring); } // check for bad menusection
			arrayindex=substring(menuliststring,menuliststringpos,menuliststringpos+1);
			arrayindex=parseInt(arrayindex);
			menulistelementsarray[arrayindex]=""+menulistelementsarray[arrayindex]+";"+menuval;
		    } else {
		    if ( debuglevel>=85) { print("menuvalue: "+menuval+" had no valid scanner in "+scannerlist); }
		}
	    } else {
		exit("Bad line detected  at linenumber:"+linenum+" in recon menu txt file "+engine_recongui_menu_path+"\n    <"+line+">\nLine should contain ;, with form MENUTYPE;menuname or value;validscanner;validscanner2;validscanner3");
		menuval="BLANK";
		scannerlist="BLANK";
	    }
	}
	linenum++;
    } while (linenum!=reconmenu.length );
} else {
    exit("ERROR could not find recon_menu file "+engine_recongui_menu_path);
}
if (debuglevel >= 65) { Array.print(menulistelementsarray); }
// Load Vars saved last time
// may use date and time, keep last 10 or something.... think that is for the future
//getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec) 
//previous_param_file_name="create_gui_info_imagej_lastsettings"+scanner+".param"; // last settings param/headfile.
previous_param_file=engine_recongui_paramfile_directory+"/"+previous_param_file_name; // path to last settings
if(File.exists(previous_param_file))
  {
      if ( debuglevel >=35 ){ print("Found Previous vars in file "+previous_param_file); }
      paramsettings=File.openAsString(previous_param_file);
      paramsettings=split(paramsettings,"\n");
//       ////
//       // For loop to pull variables, might be nice to do this based on a var list to make it more general
//       ////
//       for(linenum=0;linenum<paramsettings.length;linenum++) {
// 	line=enginesettings[linenum];
// 	temp=split(line,"=");
// 	if(startsWith(line,"minrunnumber") ) { minrunnumber=temp[1]; }
// 	else if (startsWith(line,"civmid") ) { civmid=temp[1]; }
// 	else if (startsWith(line,"coil") ) { coil=temp[1]; }
// 	else if (startsWith(line,"focus") ) { focus=temp[1]; }
// 	else if (startsWith(line,"hfpmcnt") ) { hfpmcnt=temp[1]; }
// 	else if (startsWith(line,"nucleus") ) { nucleus=temp[1]; }
// 	else if (startsWith(line,"optional") ) { optional=temp[1]; }
// 	else if (startsWith(line,"orient") ) { orient=temp[1]; }
// 	else if (startsWith(line,"rplane") ) { rplane=temp[1]; }
// 	else if (startsWith(line,"specid") ) { specid=temp[1]; }
// 	else if (startsWith(line,"species") ) { species=temp[1]; }
// 	else if (startsWith(line,"state") ) { state=temp[1]; }
// 	else if (startsWith(line,"status") ) { status=temp[1]; }
// 	else if (startsWith(line,"type") ) { type=temp[1]; }
// 	else if (startsWith(line,"xmit") ) { xmit=temp[1]; }
// 	else if (startsWith(line,"text") ) { text=temp[1]; }
// 	else { }
//     }
      linenum=0;
      do {
	  line=paramsettings[linenum];
	  temp=split(line,"="); //splits each line into the menuname, value, menuname is temp[0], and value is temp[1]
	  if(matches(menuliststring,".*"+temp[0]+".*")) // checks that this menuname is in our list of menuitms, else its ignored
	      {
		  menuliststringpos=indexOf(menuliststring,temp[0])-1;
		  if (menuliststringpos <= -1) { exit("could not find menuname: <"+menuname+">"); }
		  else { 
		      //		      print(menuliststringpos);
		      arrayindex=substring(menuliststring,menuliststringpos,menuliststringpos+1);
		      arrayindex=parseInt(arrayindex);
		      menuvalarray[arrayindex]=temp[1];
		  }
	      } 
	  else if(lengthOf(temp)>1) {
	      if (startsWith(line,"specid") ) { 
		  if (matches(temp[1],specidpattern)) { specid=temp[1]; } // only used saved specid if its good
	      }
	      else if (startsWith(line,"xmit") ) { xmit=parseFloat(temp[1]); }
	      else if (startsWith(line,"optional") ) { optional=temp[1]; }
	      else {
		  print("ignoring menuname:"+temp[0]+" with value:"+temp[1]+" recon menu ALLMENUTYPES line must have been updated to remove this");
	      }
	  }
	  else {
	      print("ignoring line <"+line+">");
	  }
	  linenum++;
      } while(linenum<lengthOf(paramsettings));
  } else {
    print("No previous param file found at "+previous_param_file);
}


////
// set up gui for display
////
uselast=getBoolean("Use last saved values?");

// loop while our output is not good, assume good output at first, then check for bad once we read it back
do {
    outputgood=1;
    Dialog.create("IMAGEJ: create_recon_gui");
    if(uselast==0) {
	specid="000000-1:0";
	xmit=0;
	optional="";		
    }
    Dialog.addString("specid:\t",specid,15);
    menuitem=0;	      
    do { 
	menuname=substring(menulistarray[menuitem],1);
	menuname=""+menuname+":"; // make display pretty by put colon on end of menuname before padding
	while(lengthOf(menuname)<largestvariablenamelength){ menuname=""+menuname+" "; } // make display pretty by pading end of menuname 
	choices=split(menulistelementsarray[menuitem],";");
	if(uselast==0) { menudefault=""; }
	else { menudefault=menuvalarray[menuitem]; }
	Dialog.addChoice(""+menuname+"\t",choices,menudefault);
	menuitem++;
    } while (menuitem<lengthOf(menulistarray));
    Dialog.addNumber("xmit:\t",xmit,0,4,"");
    Dialog.addString("optional:\t",optional,80);
    Dialog.addCheckbox("Testmode:\tTest scan WILL NOT be admitted to database.",false);
    Dialog.show();
    
    ////
    // get values from gui and check for errors, setting outputgood to 0 if bad
    ////
    specid=Dialog.getString();
    menuitem=0;
    do { 
	arrayindex=substring(menulistarray[menuitem],0,1);
	//    arrayindex=parseInt(arrayindex);
	//    if (arrayindex <=0 ) { exit("possible error with index into menulistarray at menuitem["+menuitem+"]"); }
	menuname=substring(menulistarray[menuitem],1);
	menuvalarray[arrayindex]=Dialog.getChoice(); 
	if(menuvalarray[arrayindex]==0) { outputgood=0; print("bad output for value"+menuname);}
	menuitem++;
    } while (menuitem<lengthOf(menulistarray));
    xmit=parseFloat(Dialog.getNumber());
    optional=Dialog.getString();
    testmodebool=Dialog.getCheckbox();
    if(testmodebool==true) {
	testmodebool=getBoolean("Test scan WILL NOT be admitted to database. Is that ok?");
    }
    if(testmodebool==false) {
	//sanitize specid
	if (!matches(specid,specidpattern)) { 
	    outputgood=getBoolean("Bad specid:<"+specid+"> did not match pattern<"+specidpattern+"> Ignore?\nNOTE:specid wont be saved in param file, you cant do this during a radish run." );
	} else if ( specid=="000000-1:0" ){ 
	    showMessageWithCancel("Bad Specid <"+specid+"> Please enter a valid specid");
	    outputgood=0; 
	}
	if(xmit<=100.0 && xmit>=0) {//xmitgood do nothing
	} else {//else set bad and display message
	    showMessageWithCancel("Bad xmit:<"+xmit+"> Xmit must be a number between 0-100.0");
	    outputgood=0;
	}
	if(lengthOf(optional)>240) {
	    outputgood=0;
	}
    } else {
	specid="test";
	menuitem=0;
	do { 
	    arrayindex=substring(menulistarray[menuitem],0,1);
	    //    arrayindex=parseInt(arrayindex);
	    //    if (arrayindex <=0 ) { exit("possible error with index into menulistarray at menuitem["+menuitem+"]"); }
	    menuname=substring(menulistarray[menuitem],1);
	    menuvalarray[arrayindex]="test"; 
	    menuitem++;
	} while (menuitem<lengthOf(menulistarray));	    
	xmit="test";
	optional="test";
    }
    uselast=1;
} while(outputgood==0);

/////
// save vars to file here.
////
outtext="";
menulistarray=split(menuliststring,";");
Dialog.addString("specid:\t",specid,15);
if(specid!="") { outtext=""+outtext+"specid="+specid+"\n"; }
menuitem=0;	      
do { 
    menuname=substring(menulistarray[menuitem],1);
    choices=split(menulistelementsarray[menuitem],";");
    outtext=""+outtext+menuname+"="+menuvalarray[menuitem]+"\n";
    menuitem++;
} while (menuitem<lengthOf(menulistarray));
if (optional!="") { outtext=""+outtext+"optional="+optional+"\n"; }
outtext=""+outtext+"xmit="+xmit+"\n";
if(testmodebool==false) {
    print("param file save to "+previous_param_file);
    File.saveString(outtext,previous_param_file); // saves to previous param file, each time, somewhat confusing... but suckit!
}







exit; 



//// END OF REAL CODE EXAMPLE CRAP FOLLOWS



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
