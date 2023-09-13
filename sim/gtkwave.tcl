### --------------------------------------------------------------------
### gtkwave.tcl
### Author: William Ughetta
### --------------------------------------------------------------------

# Resources:
# Manual: http://gtkwave.sourceforge.net/gtkwave.pdf#Appendix-E-Tcl-Command-Syntax
# Also see the GTKWave source code file: examples/des.tcl

# Add all signals
set nfacs [ gtkwave::getNumFacs ]
set all_facs [list]
for {set i 0} {$i < $nfacs } {incr i} {
    set facname [ gtkwave::getFacName $i ]
    # add signals declared in dut
    #if {[regexp {^.*dut\.*[^.]*$} $facname]} {
        lappend all_facs "$facname"
    #}
    #puts "$facname"
}
set num_added [ gtkwave::addSignalsFromList $all_facs ]
puts "num signals added: $num_added"

# zoom full
gtkwave::/Time/Zoom/Zoom_Full

# Print
#set dumpname [ gtkwave::getDumpFileName ]
#gtkwave::/File/Print_To_File PDF {Letter (8.5" x 11")} Minimal $dumpname.pdf