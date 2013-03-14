////////////////////////////////////////////////////////////////////////////////
// Create_gui_info_imagej
// A feature compatabile replacement for the tcl gui for radish.
// Imagej chosen for cross platform compatabiltiy, and minimal install size
//
// this script replaces 4 files which had the same/similar purpose
// recon_interface.tcl, the tcl gui
// recon_menu_items.tcl, a tcl recon_menu.txt deffinition parser which only gets 
//                      the all items line. this is used when we are using a 
//                      param file
// create_paramfile.perl, the basis for create_gui_info, takes simple arguments, 
//                        does no error checking
// create_gui_info.perl, create_gui_info, which took scanner param file, scanner 
// could be a name
//
// sally's recon_interface echos everything back to the console to pass its
// reconinterface echoed everything back in pairs like name:::value 
// recon_menu_items echoed a space separated list of valid menus's 
//                  ex civmid specid someothermenuname
// 
// Operating modes 
// This macro has 3 operating modes to satisify the different conditions under 
// which param file code was called. 
// mode 1 "standalone"
//   input:   engine_raidsh_dependencies scanner paramfilename          
//   output:  paramfile is output to dir_param_files/paramfilename 
//   ex call: java -mx1600m -jar ij.jar -batch create_gui_info_imagej.ijm engine_naxos_radish_dependencies onnes test.param
// mode 2 "inline"
//   input: eninge_deps menu_file magnet
//   output: echoed as name:::value pairs
//   ex call: 
// mode 3 "getvalidargs"
//   input: engine_deps menu_file magnet check
//   output: 
//   ex call: 
////////////////////////////////////////////////////////////////////////////////


//getVersion()
requires(1.45);
debuglevel=00;
//// switching to a three mode setup,
// expects 3-4 arguments in order,
// mode1 standalone args: engine_deps scanner paramfile, output is a filled paramfile at paramdir/paramfile
//   mode 1 replces create_paramfile.perl from tcl_dir and/or create_gui_paramfile.perl from create_gui_paramfile
//   ex call create_paramfile.perl $magnet_tesla $outfilename   creates the outfilename head file in the paramfiles dir.
//
// mode2 inline mode args: engine_deps menu_file magnet, output is echoed to console as name:::value pairs, and saved at param_dir/lastsettings_scannertesla.param
//   mode 2 replaces recon_interface.tcl from tcldir
//   ex call recon_interface menu_file scanner_tesla
//   param file is saved to default location as last settings.
//
// mode3 process allmenuitems list args: engine_deps menu_file
//
// engine_deps should be the full path to the engine dependency file usually in
//   /recon_home/script/dir_radish/engine_`hostname -s`_radish_dependencies

////
// handle multi-platform troubles
////
// detect windows or mac environmet and modify settings accordingly,
// detect if we're on zeiss or not.

////
// define constants
////
arglist=getArgument();
arglist=split(arglist," ");
//scanner_tesla_pattern="([a-zA-Z]+[0-9]*([.][0-9]*)?t)";
scanner_tesla_pattern="[A-z]?[0-9]+([.][0-9]+)?t"; // corresponding to the 7t b7t 9t stuff. could match a00.00t, which is [letter][decimalnumber]t
// for non magnet scanners using [modality letter]+0.0t
optional_field_length=80;
valid_scanner_pattern="([a-zA-Z]+[0-9]*([.][0-9]*)?t)|([a-zA-Z._0-9]*)";
engine_dependency_filepath=arglist[0]; // this should be passed by clever alias when called in standalone mode.
if (!File.exists(engine_dependency_filepath) ) { 
  exit("Could not find dependency file, cannot continue\nFile=<"+engine_dependency_filepath+">\n");
 }
dialogerrordisplaystring="";

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
year=toString(year);
while(lengthOf(year)<4) {year="0"+year;}	    
month=toString(month+1);
while(lengthOf(month)<2) {month="0"+month;}
dayOfMonth=toString(dayOfMonth);
while(lengthOf(dayOfMonth)<2) {dayOfMonth="0"+dayOfMonth;}
hour=toString(hour);
while(lengthOf(hour)<2) {hour="0"+hour;}
minute=toString(minute);
while(lengthOf(minute)<2) {minute="0"+minute;}
second=toString(second);
while(lengthOf(second)<2) {second="0"+second;}
datetimestamp=""+year+month+dayOfMonth+hour+minute+second;
datetimestamp=""; // We have decided that the date time stamp functionality is bad. It breaks radish_scale_bunch because radish_scale_bunch assumes a param file name, and this changes that name.
radishdate=""+month+"/"+dayOfMonth+"/"+substring(year,2);

useageerror=1; //init to usage-error true
if(lengthOf(arglist)>=2) {
    if (matches(arglist[1],valid_scanner_pattern) && lengthOf(arglist)==3 ) { 
	// 
	// mode 1 standalone
	mode="standalone";
	//	debuglevel=100;
	scanner=arglist[1];
	param_file_prefix=arglist[2];
	previous_param_file_name=""+param_file_prefix; //+".param";
	temp=split(previous_param_file_name,".");
	param_file_prefix=temp[0];
	param_file_postfix="";
	if(lengthOf(temp)>1) {
	    ti=1;
	    do {
		param_file_postfix="."+param_file_postfix+temp[ti];
		ti=ti+1;
	    } while(ti<lengthOf(temp)) ; 
	}
	next_param_file_name=""+param_file_prefix+datetimestamp+param_file_postfix; //+".param";
	modemessage="Function mode: "+mode+" - Standalone called via cmdprompt to prepare a param file before calling radish\n"; 
	//Tried to load: "+previous_param_file_name;
	useageerror=0;
	print("mode:"+mode);
    } else if(File.exists(arglist[1])) {
	if(lengthOf(arglist)==3) {
	    //mode 2 inline
	    mode="inline";
	    menu_file=arglist[1];
	    scanner=arglist[2]; // exptcted as scanner name or tesla.
	    previous_param_file_name="create_gui_info_imagej_lastsettings_"+scanner+".param"; // last settings param/headfile.
	    next_param_file_name=previous_param_file_name;
	    modemessage="Function mode: "+mode+" - This is called during recon.";
	    //	    debuglevel=100;
	    useageerror=0;
	    print("mode:"+mode);
	} else if(lengthOf(arglist)==4) {
	    if (arglist[3]=="check") {
		//mode 3 getvalidparam names
		mode="getvalidargs";
		menu_file=arglist[1];
		scanner=arglist[2];
		//	    ischeck=arglist[3];
		previous_param_file_name="";
		next_param_file_name=previous_param_file_name;
		modemessage="Function mode: "+mode+" - This is called during recon, when only the recon menu text is used";
		//	    debuglevel=100;
		useageerror=0;	    
		print("mode:"+mode);
	    } else { 
		useageerror=1;	    
	    }
	} else {
	    exit("COULD NOT GET RECON MENU.txt file!");
	    useageerror=1;
	}
    } 
}
if (useageerror==1) {
    args="";
    argcount=lengthOf(arglist)-1;
    for(i=1;i<lengthOf(arglist);i++) { args=""+args+arglist[i]+"," ; }
    exit("Usage Error: \
    Bad arguments on command line; need 2 found "+argcount+".  Recieved args: "+args+"\
Standard Usage: create_info_gui_imagej scanner new_file_name\
\
    Program to make a gui parameter file which can be used by -p option of radish.\
    Use -p in radish to stop it from asking for scan info via\
      the GUI (graphical user interface).\
    When -p is used radish will read settings from the gui parameter file\
      you specify instead.\
    2 args required:\
\
    scanner:        Name of magnet that will produce data, e.g.\
                    heike, onnes, kamy, nemo, dory, 2t, 7t, 9t, b7t,\
    new_file_name:  File name of the gui parameter file that\
                    will be produced by this program.\
                    if it already exists it will not be overwritten.\
\
    Param file storage location set by recon engine parameter \"engine_recongui_paramfile_directory\"\;\
      usually stored in /recon_home/dir_param_files\
    ");
}
// if scanner is given as a name instead of a tesla value figure out the scanner dependecny file and load that to get the scanner_tesla
if ( !matches(scanner,scanner_tesla_pattern) && mode !="getvalidargs" ) {
    getscannertesla=1;
    RADISH_RECON_DIR=File.getParent(engine_dependency_filepath);   // pull main recondir from the engine_dependency_filepathpath
    scanner_dependency_filename="scanner_"+scanner+"_radish_dependencies";
    scanner_dependency_filepath=""+RADISH_RECON_DIR+"/"+scanner_dependency_filename;
} else {
    // need somehow to say if we've got a bogus scanner tesla value, not sure where to do that. 
    dialogerrordisplaystring="Scanner Tesla Specified directly, Empty Drop down menus indicates bad scanner tesla. Try using a name.\n";
    getscannertesla=0;
}

////
// radish settings to get relevant info for script.
////
//engine_dependency_filepath="/recon_home/script/dir_radish/engine_"+hostname+"_radish_dependencies";

////
// option vars
////

////
// load instructions for display at top of the dialog box.
////

////
// Load files
////
//scanner settings , only need one value, shame to do it this way, but this will cover all bases
if(getscannertesla==1) {
    if(debuglevel>=50) { print("Getting Scanner Tesla"); }
    if(File.exists(""+scanner_dependency_filepath)) {
	scannersettings=File.openAsString(""+scanner_dependency_filepath);
	scannersettings=split(scannersettings,"\n");
	for(linenum=0;linenum<scannersettings.length;linenum++) {
	    temp=split(scannersettings[linenum],"=");
	    if(matches(temp[0],"scanner_tesla")) {
		scanner=temp[1];
	    }
	}
    } else {
	exit("ERROR could not get scanner tesla. Did not find scanner_dependency_file at path:"+scanner_dependency_filepath+" for scanner "+scanner);
	//, something is wrong If error perists notify james.
    }
    if(!matches(scanner,scanner_tesla_pattern)) {
	exit("ERROR could not get scanner tesla. Did not find scanner_dependency_file at path:"+scanner_dependency_filepath+" for scanner "+scanner);
    }
}
if(debuglevel>=50) {
    print("scanner:                  "+scanner);
    print("previous_param_file_name: "+previous_param_file_name);
}
//radish settings
if(File.exists(""+engine_dependency_filepath)) {
    enginesettings=File.openAsString(""+engine_dependency_filepath);
    enginesettings=split(enginesettings,"\n");
    for(linenum=0;linenum<enginesettings.length;linenum++) {
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
    exit("ERROR could not find enginesetting file "+engine_dependency_filepath);
}
if(mode!="standalone") {
    engine_recongui_menu_path=menu_file;
}
if ( debuglevel >= 45 ) {
    print("engine_dependency_filepath:          "+engine_dependency_filepath);
    print("engine_recongui_paramfile_directory: "+engine_recongui_paramfile_directory);
    print("engine_recongui_menu_path:           "+engine_recongui_menu_path);
    print("engine_work_directory:               "+engine_work_directory);
    print("engine_archive_tag_directory:        "+engine_archive_tag_directory);
    }
//recon_menu.txt
reconmenucomments="";
menuliststring="";        // semi-colon seperated string for each menuname type. with index prepended to name
allmenus="";              // mode3 variable to hold all the menus in a space separated list
// the size of these arrays cant be set until we know how many menunames we have, we find that out once we read ALLMENUTYPES
menulistelementsarray=""; // array of semi-colon seperated strings, one array element per menuname item
menuvalarray="";          // array of strings, the previous and currently selected values for each menutname item

//default settings
specidpattern="([0-9]{6}-[0-9]*:[0-9]*)(;[0-9]{6}-[0-9]*:[0-9]*)*";
codepattern="([0-9]{2}.[a-zA-Z]+.[0-9]{2})";
//runnopattern="([A-Z][0-9]{5,}([A-Za-z_-][A-Za-z0-9_-])*)";
runnopattern="([A-Z][0-9]{5,}([A-Za-z_-][A-Za-z0-9_-]*)?)";	
specid="000000-1:0";
xmit=0;
optional="";
length_of_longest_menuname=0;//setting to be used latter to make display pretty
////
// load recon_menu.txt
////
// buildsvariables  menuliststring, menuvalarray, number_menu_items, maxlength_menu_number, length_of_longest_menuname
//    column header liststring of the form #menuname;#menuname2  to be split up later during display
//    data columns, an array of liststrings with the values allowed for each header entry.
//    number_menu_items, derp
//    maxlength_menunumber, how long the number_menu_itmes value is as a string, this is to do evenly spaced digits later. 
//    length_of_longest_menuname, holds the character count of the longest menuname, used during display.
if(File.exists(""+engine_recongui_menu_path)) {
    reconmenu=File.openAsString(""+engine_recongui_menu_path);
    reconmenu=split(reconmenu,"\n");
    linenum=0;
    do {
	line=reconmenu[linenum];
	// line should be split taking the first item as the value the second as the scanner list.
	// menuvalue;
	// scannerlist;
	if (startsWith(line,"#")) { // # comments ignore
	    reconmenucomments=""+reconmenucomments+"\n"+line; if (debuglevel>=85 ) { print("commentline:"+line); } 
	} else if (matches(line,".*TYPE.*")){
	    //	    print ("typematch");
	    if(startsWith(line,"ALLMENUTYPES")) { //build the menuliststring, same as the ALLMENUTYPES line but it includes the array index for the menuvals
		temparray=split(line, ";");
		
		number_menu_items=lengthOf(temparray);                      //padhandling
		maxlength_menunumber=lengthOf(toString(number_menu_items)); //padhandling
		for(i=1;i<number_menu_items;i++) {                          //loop to build menuliststring
		    paddedmenunum=toString(i-1);                            //padhandling
		    while(lengthOf(paddedmenunum)<maxlength_menunumber) { paddedmenunum="0"+paddedmenunum; } //padd out number in array
		    if (debuglevel>=90) { print(temparray[i]); }
		    varlength=lengthOf(temparray[i]);
		    if(length_of_longest_menuname<varlength) { length_of_longest_menuname=varlength; }
		    menuliststring=""+menuliststring+paddedmenunum+temparray[i]+";";
		}
		menulistarray=split(menuliststring,";");
		menulistelementsarray=newArray(i); //
		menuvalarray=newArray(i);          //
		for(i=0;i<lengthOf(menuvalarray);i++) { menuvalarray[i]=""; }
		if (debuglevel>=55) { print("all expected menu items: "+menuliststring); }
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
		////
		// this simple line mostly works for scanners which are not short named similarly,
                // however if onescanner's name is contained in another this creates a partial match,
		//  hopefully new lines below fixes that, patch goes to if(match)
		//if(matches(scannerlist,".*"+scanner+".*")) 
		scannerarray=split(scannerlist,";");
		match=false;
		for(i=0;i<lengthOf(scannerarray);i++){ 
		    if(matches(scannerarray[i],"^"+scanner+"$"))
			{
			    match=true;
			    i=lengthOf(scannerarray); // in lieu of a break statement
			}
		}
		if(match)
		////
		    { // if our scanner is in the list of valid scanners for this option add
			//menuliststringpos=indexOf(menuliststring,menuname)-1;//maxlength_menunumber
			menuliststringpos=indexOf(menuliststring,menuname)-maxlength_menunumber;
			if (menuliststringpos <= -1 ) { exit("could not find menuname: <"+menuname+"> in list of all menunames: "+menuliststring); } // check for bad menusection
			//arrayindex=substring(menuliststring,menuliststringpos,menuliststringpos+1);//maxlength_menunumber
			arrayindex=substring(menuliststring,menuliststringpos,menuliststringpos+maxlength_menunumber);
			arrayindex=parseInt(arrayindex);
			menulistelementsarray[arrayindex]=""+menulistelementsarray[arrayindex]+";"+menuval;
			if (  ! matches(allmenus,".*"+menuname+".*")) {
			    allmenus=""+allmenus+menuname+" ";
			}
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
////
//dumps the allmenus arg out and quits for the param file check where we check that we only specifiy valid params
////
if (mode=="getvalidargs") { exit(""+allmenus+"specid xmit optional status"); }

if (debuglevel >= 65) { Array.print(menulistelementsarray); }
uselastsettings_boolean=0;
// Load Vars saved last time
// may use date and time, keep last 10 or something.... think that is for the future
//previous_param_file_name="create_gui_info_imagej_lastsettings"+scanner+".param"; // last settings param/headfile.
previous_param_file=engine_recongui_paramfile_directory+"/"+previous_param_file_name; // path to last settings
//next_param_file=engine_recongui_paramfile_directory+"/"+next_param_file_name; // path to next settings changed this to be set below for better usage when previous param isnt available
if(File.exists(previous_param_file))
  {
      if ( debuglevel >=35 ){ print("Found Previous vars in file "+previous_param_file); }
      paramsettings=File.openAsString(previous_param_file);
      paramsettings=split(paramsettings,"\n");
      linenum=0;
      do {
	  line=paramsettings[linenum];
	  temp=split(line,"="); //splits each line into the menuname, value, menuname is temp[0], and value is temp[1]
	  if(matches(menuliststring,".*"+temp[0]+".*")) // checks that this menuname is in our list of menuitms, else its ignored
	      {
		  menuliststringpos=indexOf(menuliststring,temp[0])-maxlength_menunumber;
		  if (menuliststringpos <= -1) { exit("ERROR: could not find menuname: <"+temp[0]+"> in menulist <"+menuliststring+">"); }
		  else {
		      arrayindex=substring(menuliststring,menuliststringpos,menuliststringpos+maxlength_menunumber);
		      arrayindex=parseInt(arrayindex);
		      choices=split(menulistelementsarray[arrayindex],";");
		      //		      if(
		      //if (choices[1]=="Number" || choices[1]=="String"){ //choices[1]=="Number"
		      if(lengthOf(choices)>=2) { 
			  if(matches(menulistelementsarray[arrayindex],".*"+temp[1]+".*") 
			     || choices[1]=="Number" 
			     || choices[1]=="String" ) {
			      menuvalarray[arrayindex]=temp[1];
			      
			      if (debuglevel>=50) { print("Loaded value "+menuvalarray[arrayindex]+" to position "+arrayindex); }
			  }
		      } else { 
			  dialogerrordisplaystring=""+dialogerrordisplaystring+"invalid value for item: "+temp[0]+" with value: "+temp[1]+"\n";
			  menuvalarray[arrayindex]=0;
		      }
		  }
	      }
	  else if(lengthOf(temp)>1) {
	      if (startsWith(line,"specid") ) {
		  if (matches(temp[1],specidpattern)) { 
		      specid=temp[1]; 
		  } else { 
		      dialogerrordisplaystring=""+dialogerrordisplaystring+"invalid value for item: "+temp[0]+" with value: "+specid+" does not match pattern:"+specidpattern+"\n";
		  }
	      } else if (startsWith(line,"optional") ) { optional=temp[1]; 
	      } else if (matches(line, ".*(recongui_date|version_pm_Headfile|status|hfpmcnt).*")) {
	      } else {
		  dialogerrordisplaystring=""+dialogerrordisplaystring+"invalid name for item: "+temp[0]+" with value:"+temp[1]+" name not in ALLMENUTYPES list, Do you have the right scanner?\n ";//recon menu ALLMENUTYPES line must have been updated to remove this\n";
	      }
	  }
	  else {
	      if(!startsWith(line,"optional=")) {
		      dialogerrordisplaystring=""+dialogerrordisplaystring+"BAD LINE AT LINENUM:"+linenum+"<"+line+">\n"; }
	      if (debuglevel>=50) { print("ignoring line <"+line+">"); }
	  }
	  linenum++;
      } while(linenum<lengthOf(paramsettings));
      uselastsettings_boolean=getBoolean("Use last saved values?");
  } else {
    next_param_file_name=previous_param_file_name;
    if (debuglevel>=55 ){ print("No previous param file found at "+previous_param_file+". Or No param file specified."); }
    uselastsettings_boolean=0;
}
if(uselastsettings_boolean==1) {
    loadmessage="Loaded file:    "+previous_param_file_name; 
} else {
    // this is actually a lie : ) we always load if there is a file to load, we just wont display those values in the defaults.
    loadmessage="Did not load a file.";
    dialogerrordisplaystring="";
}
if(dialogerrordisplaystring=="") {
    dialogerrordisplaystring="<NONE>";
}
next_param_file=engine_recongui_paramfile_directory+"/"+next_param_file_name; // path to next settings
savemessage=  "Saving file to: "+next_param_file_name;
////
// set up gui for display
////
if(debuglevel>=50) { print("Starting dialog setup"); }
// loop while our output is not good, assume good output at first, then check for bad once we read it back
do {
    outputgood=1;
    Dialog.create("IMAGEJ: create_recon_gui");
    Dialog.addMessage(""+modemessage+"\n"+loadmessage+"\n"+savemessage+"\nLoding and saving to "+engine_recongui_paramfile_directory);
    Dialog.addString("outfilename",next_param_file_name,lengthOf(next_param_file_name));
    Dialog.addMessage("Warnings:\n"+dialogerrordisplaystring);
    dialogerrordisplaystring="";
    if(uselastsettings_boolean==0) {
	specid="000000-1:0";
	xmit=0;
	optional="";
    }
    Dialog.addString("specid:\t",specid,15);
    menuitem=0;
    ignored_menuitems="";
    do {
	menuname=substring(menulistarray[menuitem],maxlength_menunumber);
	menuname=""+menuname+":"; // make display pretty by put colon on end of menuname before padding
	while(lengthOf(menuname)<length_of_longest_menuname){ menuname=""+menuname+" "; } // make display pretty by pading end of menuname
	choices=split(menulistelementsarray[menuitem],";");
	if(uselastsettings_boolean==0) { menudefault=""; } else { menudefault=menuvalarray[menuitem]; }
	// could sneak an if there are any entries here to ignore any without options, maybe add to an ignored list to be displayted at bottom of menu.

// 	if (matches(menuname,".*xmit.*")) { 
// 	    print("Choices 0 = "+choices[0]+"length is "+toString(lengthOf(choices))+"\n"); 
// 	} else { 
// 	    print(menuname+" Choices 0 = "+choices[0]+"length is "+toString(lengthOf(choices))+"");
// 	}
	if (lengthOf(choices) >=2 ) { //lenght is 2 for 2 elements but max index would be 1 like c style string
	    if (choices[1]!="Number" && choices[1]!="String"){ //choices[1]=="Number"
		Dialog.addChoice(""+menuname+"\t",choices,menudefault);
	    } else if(choices[1]=="Number") {
		Dialog.addNumber(""+menuname+"\t",0,0,4,menudefault);
	    } else if(choices[1]=="String") {
		if (lengthOf(choices)>=3 && (toString(menudefault)=="" || toString(menudefault)=="0")) {
		    menudefault=choices[2];
		}
		Dialog.addString(""+menuname+"\t",menudefault,20);
	    }
	} else if ( matches(menuname,".*(civmid).*")) {
	    if(debuglevel>=85) { print("choices are being killed "+menulistelementsarray[menuitem]+"\n"); }
	    Dialog.addString(""+menuname+"\t","NO_USERS_REGISTERED",20);
	    dialogerrordisplaystring=dialogerrordisplaystring+"Required menu "+menuname+" had no entries, MUST TELL LUCY/JAMES \n";//choice string="+menulistelementsarray[menuitem]+"\n";
	} else if ( matches(menuname,".*(code).*")) {
	    //	    Dialog.addString(""+menuname+"\t","NO_USERS_REGISTERED",20);
	    //	    dialogerrordisplaystring=dialogerrordisplaystring+"Required menu "+menuname+" had no entries, MUST TELL LUCY/JAMES \n";//choice string="+menulistelementsarray[menuitem]+"\n";
	    waitForUser("NO PROJECT CODE ERROR\n"+"ERROR: CANNOT CONTINUE\nTHERE IS NO REGISTERED CODE FOR THIS SCANNER!\n\nTell lucy and james immediately that scanner:"+scanner+" has no entries!\n");
	    //showMessageWithCancel
	    exit("ERROR:ERROR:ERROR:ERROR:ERROR:ERROR:ERROR:ERROR:ERROR:ERROR:ERROR:ERROR:ERROR:ERROR:ERROR:ERROR:ERROR:ERROR:");
	} else {
	    if(debuglevel>=50) { print("ignored menuitem  "+menuname+" with choices"+menulistelementsarray[menuitem]+"\n"); } 
	  ignored_menuitems=""+ignored_menuitems+menuname+" ";
	}
	menuitem++;
    } while (menuitem<lengthOf(menulistarray));
    Dialog.addString("optional:\t",optional,80);
    Dialog.addCheckbox("Testmode:\tTest scan WILL NOT be admitted to database and Values are NOT SAVED.",false);
    Dialog.addMessage("Ignored Items:"+ignored_menuitems);
    Dialog.show();

    ////
    // get values from gui and check for errors, setting outputgood to 0 if bad
    ////
    different_param_file_name=Dialog.getString();
    specid=Dialog.getString();
    menuitem=0;
    do {
	arrayindex=substring(menulistarray[menuitem],0,maxlength_menunumber);
	menuname=substring(menulistarray[menuitem],maxlength_menunumber);
	choices=split(menulistelementsarray[menuitem],";");
	// could sneak an if there are any entries here to ignore any without options, maybe add to an ignored list to be displayted at bottom of menu.
	if (lengthOf(choices) >=2  ) { //lenght is 2 for 2 elements but max index would be 1 like c style string
	    if (choices[1]!="Number" && choices[1]!="String"){ //should switch this around to be the else condition 
		menuvalarray[arrayindex]=Dialog.getChoice();
		if(menuvalarray[arrayindex]==0) { outputgood=0; dialogerrordisplaystring=""+dialogerrordisplaystring+"unset output for item:"+menuname+"\n"; }
		if(debuglevel>=50) { print("recieved Choice "+menuname+"="+menuvalarray[arrayindex]); }
	    } else if(choices[1]=="Number" ) {
		menuvalarray[arrayindex]=Dialog.getNumber();
		//		print("expermental code for adding number to menu\n"); 
	    } else if(choices[1]=="String") {
		menuvalarray[arrayindex]=Dialog.getString();//Dialog.addString(""+menuname+"\t",menudefault,20);
		//		print("expermental code for adding string to menu\n"); 
	    }	
	} else if ( matches(menuname,".*(civmid|code).*")) {
	    menuvalarray[arrayindex]=Dialog.getString();//""+menuname+"\t","<NOCHOICESFOUND>",20);
	} 
	menuitem++;
    } while (menuitem<lengthOf(menulistarray));
    
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
	    //	    showMessageWithCancel("Bad Specid <"+specid+"> Please enter a valid specid");
	    dialogerrordisplaystring="bad output for item:specid <"+specid+"> Please enter a valid specid\n"+dialogerrordisplaystring;
	    outputgood=0;
	}


	menuitem=0;
	do {
	    arrayindex=substring(menulistarray[menuitem],0,maxlength_menunumber);
	    menuname=substring(menulistarray[menuitem],maxlength_menunumber);
	    choices=split(menulistelementsarray[menuitem],";");
	    if (lengthOf(choices) >=2  ) { //lenght is 2 for 2 elements but max index would be 1 like c style string
// 		if (choices[1]!="Number" && choices[1]!="String"){ //choices[1]=="Number"
		    
// 		    //		    if(menuvalarray[arrayindex]==0) { outputgood=0; dialogerrordisplaystring=""+dialogerrordisplaystring+"unset output for item:"+menuname+"\n"; }
// 		    //menuvalarray[arrayindex]=Dialog.getChoice();
// 		    //do no checking for choice values, 
// 		} else {
		    //if number
		    if (matches(menuname,".*xmit.*")) {
			if(parseFloat(menuvalarray[arrayindex])>100.0 || parseFloat(menuvalarray[arrayindex])<0) {//xmitgood do nothing
			    dialogerrordisplaystring=""+dialogerrordisplaystring+"Bad xmit:<"+menuvalarray[arrayindex]+"> Xmit must be a number between 0-100.0\n";
			    outputgood=0;
			}
		    } else if (matches(menuname,".*runno.*")) { 
			if (! matches(menuvalarray[arrayindex],runnopattern)) {
			    dialogerrordisplaystring=""+dialogerrordisplaystring+"Bad Runnumber:<"+menuvalarray[arrayindex]+"> Runnumber must match pattern "+runnopattern+"\n";
			    outputgood=0;
			}
		    } else { 
			//was drop down no error checking required
		    }
			 
		    //}		
	    } else if ( matches(menuname,".*code.*")) {
		if ( !matches(menuvalarray[arrayindex],codepattern)){
		    dialogerrordisplaystring=""+dialogerrordisplaystring+"Malformed code:<"+menuvalarray[arrayindex]+"> should match pattern :"+codepattern+"\n";
		    outputgood=0;
		} else { 
		    menulistelementsarray[menuitem]=""+menulistelementsarray[menuitem]+";"+menuvalarray[menuitem];
		}
	    } 
	    menuitem++;
	} while (menuitem<lengthOf(menulistarray));	

	if(lengthOf(optional)>optional_field_length) {
	    optionaldisplay=""; 
	    optind=0;
	    nextbytes=50;
	    do { 
		if(optind+nextbytes>lengthOf(optional)) { nextbytes=lengthOf(optional)-optind; }
		optionaldisplay=optionaldisplay+substring(optional,optind,optind+nextbytes)+"\n";
		optind=optind+nextbytes;
	    } while(optind<lengthOf(optional))

	    dialogerrordisplaystring=""+dialogerrordisplaystring+"Bad Optional, more than "+optional_field_length+" characters entered (wrapping at 50 chars)\n<"+optionaldisplay+">";
	    outputgood=0;
	}
    } else {
	outputgood=1;
	specid="test";
	menuitem=0;
	do {
	    arrayindex=substring(menulistarray[menuitem],0,maxlength_menunumber);
	    menuname=substring(menulistarray[menuitem],maxlength_menunumber);
	    menuvalarray[arrayindex]="test";
	    menuitem++;
	} while (menuitem<lengthOf(menulistarray));
	optional="test";
    }
    uselastsettings_boolean=1;
} while(outputgood==0);

/////
// save vars to file here.
////
namevalseparators=newArray(":::","=");
// if(mode=="inline") {
//     namevalseparator=":::";
// } else if (mode=="standalone") {
//     namevalseparator="=";
// } else {
//     exit("BAD MODE: MAJOR ERROR");
// }


//paramtexts=newArray("","");
if(specid!="") { 
    paramtexts=newArray("specid"+namevalseparators[0]+specid+"\n","specid"+namevalseparators[1]+specid+"\n");
    //    paramtexts[modenum]=""+paramtexts[modenum]+"specid"+namevalseparators[modenum]+specid+"\n"; 
}
//outtext="";

menulistarray=split(menuliststring,";");
for(modenum=0;modenum<2;modenum++ ) {
    menuitem=0;
    do {
	menuname=substring(menulistarray[menuitem],maxlength_menunumber);
	choices=split(menulistelementsarray[menuitem],";");
	// could sneak an if there are any entries here to ignore any without options, maybe add to an ignored list to be displayted at bottom of menu.
	if (lengthOf(choices) >1 ) {
	  paramtexts[modenum]=""+paramtexts[modenum]+menuname+namevalseparators[modenum]+menuvalarray[menuitem]+"\n";
	}
	menuitem++;
    } while (menuitem<lengthOf(menulistarray));
    //    if (optional!="") { 
    paramtexts[modenum]=""+paramtexts[modenum]+"optional"+namevalseparators[modenum]+optional+"\n"; 
	//    }
    //    paramtexts[modenum]=""+paramtexts[modenum]+"xmit"+namevalseparators[modenum]+xmit+"\n";
    paramtexts[modenum]=""+paramtexts[modenum]+"status"+namevalseparators[modenum]+"ok\n";
    paramtexts[modenum]=""+paramtexts[modenum]+"recongui_date"+namevalseparators[modenum]+radishdate; //+"\n"
    
}
paramtexts[1]=paramtexts[1]+"\n"; //special line to clean up last line not haveing new line, but we only want to do that for the param file

next_param_file=engine_recongui_paramfile_directory+"/"+different_param_file_name; // path to next settings
if(testmodebool==false) {
    //print("param file save to "+next_param_file);
    outval=File.saveString(paramtexts[1],next_param_file); // saves to previous param file, each time, somewhat confusing... but suckit!
    wait(500);
    print("save out val="+outval);
}
if(mode=="inline") {
    print(paramtexts[0]); 
} else if( mode=="standalone" ) {
    print(paramtexts[1]);
    print("Please check the contents with \n    cat  "+next_param_file+"");
}
run("Quit");    
exit;
