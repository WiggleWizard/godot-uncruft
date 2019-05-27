extends "macro_base.gd";


func expand() -> String:
	var s = \
"""
export(%type%) var %name% = %default% setget set_prop_%name%;
func set_prop_%name%(v):
	%name% = v;
	%post_func%("%name%", v);
"""

	return template(s.strip_edges());