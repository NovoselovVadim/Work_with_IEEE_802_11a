
######################################### SET YOURE PARAMETERS ###################################################

set time_raw [clock seconds];
set date_string [clock format $time_raw -format "%y%m%d_%H%M%S"]

set language "VHDL"

variable script_file
set script_file "create_project.tcl"

# Set device
set device "xcku025-ffva1156-1-i"

# Set the reference directory for source file relative paths (by default the value is script directory path)
cd [file dirname [file normalize [info script]]]
cd ..
set origin_dir [pwd]

# Set the project name
set _xil_proj_name_ "Project_$date_string"

# Set the directory path for the original project from where this script was exported
set orig_proj_dir [file normalize "$origin_dir"]

# Set the directory path for the new project
set proj_dir "$orig_proj_dir/$_xil_proj_name_"

##################################################################################################################

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
  set _xil_proj_name_ $::user_project_name
}

if { $::argc > 0 } {
  for {set i 0} {$i < $::argc} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--origin_dir"   { incr i; set origin_dir [lindex $::argv $i] }
      "--project_name" { incr i; set _xil_proj_name_ [lindex $::argv $i] }
      "--help"         { print_help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

# Create project
create_project -force ${_xil_proj_name_} "$proj_dir" -part $device
set_property target_language $language [current_project]

# Add files to new project
set SrcDir "$origin_dir/src"

set SrcVHD "$SrcDir/sources_1/new"
set SrcXCI "$SrcDir/sources_1/ip"
set SrcXDC "$SrcDir/constrs_1/new"
set SrcSIM "$SrcDir/sim_1/new"


cd $SrcXCI
foreach folders [glob -type d *] {      
    add_files -quiet [glob $SrcXCI/$folders/*.xci]
    export_ip_user_files -of_objects [get_files [glob $SrcXCI/$folders/*.xci]] -force -quiet
}
add_files -quiet [glob $SrcVHD/*.vhd]
add_files -fileset constrs_1 -quiet [glob $SrcXDC/*.xdc]
add_files -fileset sim_1 -quiet [glob $SrcSIM/*.vhd]


# Disable ReadFile and WriteFile from synthesis
set_property used_in_synthesis false [get_files  "$SrcVHD/WriteFile.vhd"]
set_property used_in_synthesis false [get_files  "$SrcVHD/ReadFile.vhd"]

# Upgrade IP Cores (if needed)
report_ip_status -name ip_status 
set IpCores [get_ips]
for {set i 0} {$i < [llength $IpCores]} {incr i} {
  set IpSingle [lindex $IpCores $i]
  
  set locked [get_property IS_LOCKED $IpSingle]
  set upgrade [get_property UPGRADE_VERSIONS $IpSingle]
  if {$upgrade != "" && $locked} {
    upgrade_ip $IpSingle
  }
}
report_ip_status -name ip_status
