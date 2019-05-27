extends "macro_base.gd";


func expand() -> String:
	var default_arg_format = "{default}";
	if(args['type'] == "String"):
		default_arg_format = "\"{default}\"";

	var declaration = "export({type}) var {name} = " + default_arg_format + " setget set_prop_{name};";

	var s = declaration + \
"""
func set_prop_{name}(v):
	{name} = v;
	{post_func}(\"{name}\", v);
"""

	return format(s);