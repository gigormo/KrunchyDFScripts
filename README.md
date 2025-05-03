# Lua Scripts for Dwarf Fortress

A collection of Lua scripts to enhance Dwarf Fortress using DFHack.

---
autosquad
==========

Tags: fort | auto

Command: "autosquad"

   Run script to automagically assign squad members by effectiveness or potential.
	
Ignores maimed or unstable dwarves.
   
Script does not automatically run, you'll need to run it anytime you want to fill squads.

Usage
-----

   autosquad [<options>]


Examples
--------

"autosquad -s effectiveness"
   Assign squad members by effectiveness
   
"autosquad -s potential"
   Assign squad members by potential

"autosquad -in maimed"
   Include maimed units
   
"autosquad -in unstable"
   Include unstable units
   
"autosquad -in maimed,unstable"
   Both includes work if seperated by a ,

Options
-------

"-s"
   Sorting priority by effectiveness(e) or potential(p). Defaults to effectiveness

"-in"
   Include maimed(m) or unstable(u) units
