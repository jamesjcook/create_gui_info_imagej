javaaddpath /Applications/ImageJ//ImageJ.app/Contents/Java/ij.jar;
import ij.ImageJ;
import ij.Macro;
import ij.macro.Interpreter;
% import ij.plugin.frame;
import ij.macro.MacroRunner;
import ij.macro.MacroExtension;
import ij.macro.Program;
import ij.Executer;
import ij.plugin.tool.PlugInTool;
% import ij.plugin.tool;

ex=Executer('About ImageJ...');ex.run(); 
pmacro ='"/Applications/ImageJ/plugins/Examples/_Macros/Pong.ijm"';


% ex=Executer('create_gui_info_imagej');ex.run();%unrecognized


ijp=ij.macro.Program

% MacroRunner
ijw=javaObjectEDT('ij.ImageJ'); % makes an imagej window.
% MacroRunner(java.lang.String macro, java.lang.String argument)
mr=MacroRunner('"/Volumes/workstation_home/software/shared/create_gui_info_imagej/create_gui_info_imagej.ijm"',...
    ['"/Volumes/workstation_home/software/ pipeline_settings/engine_deps/engine_delos_dependencies '...
    '/Volumes/workstation_home/software/pipeline_settings/recon_menu.txt 7t"']);

%quickly stops.
ijw.main(['-ijpath /Applications/ImageJ/ '...
    '-batch /Volumes/workstation_home/software/shared//create_gui_info_imagej//create_gui_info_imagej.ijm '...
    '/Volumes/workstation_home/software/ pipeline_settings/engine_deps/engine_delos_dependencies '...
    '/Volumes/workstation_home/software/pipeline_settings/recon_menu.txt 7t']);
%relatively quickly says is not a vaild file type. 
ijw.main(['/Volumes/workstation_home/software/shared//create_gui_info_imagej//create_gui_info_imagej.ijm '])
ijw.main(['run("/Volumes/workstation_home/software/shared//create_gui_info_imagej//create_gui_info_imagej.ijm")'])
%very slowly gives recon_menu is not a macro.
ijw.main(['/Volumes/workstation_home/software/shared//create_gui_info_imagej//create_gui_info_imagej.ijm '...
    '/Volumes/workstation_home/software/ pipeline_settings/engine_deps/engine_delos_dependencies '...
    '/Volumes/workstation_home/software/pipeline_settings/recon_menu.txt 7t']);
ijw.quit;