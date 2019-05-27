extends Resource
const Macro = preload("macros/macro_base.gd");

var _script: Script = null;
var _working_source: PoolStringArray = []; # Working source in memory split by new line


var _parser = preload("parser.gd").new();


func _init(script: Script):
	_script = script;
	
func clear_expanded_macros():
	_working_source = _script.source_code.split("\n");
	
	var macros = _parser.parse_script(_script);
	macros.invert();
	
	for macro in macros:
		clear_macro(macro);

	# Finally we write the working copy onto disk
	var f = File.new();
	f.open(_script.resource_path, File.WRITE_READ);
	f.store_string(_working_source.join("\n"));
	f.close();
	
func expand_macros():
	# Make a working copy of the source code in memory
	_working_source = _script.source_code.split("\n");
	
	# Parse the script to get macros
	var macros = _parser.parse_script(_script);
	
	# We want to go through the macros backwards, otherwise as
	# we add and remove from the source the found macros will move.
	macros.invert();
	
	# Now we expand the macros into the working copy of the source
	for macro in macros:
		expand_macro(macro);

	# Finally we write the working copy onto disk
	var f = File.new();
	f.open(_script.resource_path, File.WRITE_READ);
	f.store_string(_working_source.join("\n"));
	f.close();
	
func expand_macro(macro: Macro):
	clear_macro(macro);
			
	var expanded = macro.expand();
	print(expanded);
	_working_source.insert(macro.get_starting_line() + 1, expanded);
	_working_source.insert(macro.get_starting_line() + 2, Macro.MACRO_END_SUFFIX + macro.command);
	
	macro.expanded = true;
	
func clear_macro(macro: Macro):
	if(macro.expanded):
		for i in range(macro.get_ending_line(), macro.get_starting_line(), -1):
			_working_source.remove(i);
			
	macro.expanded = false;
	
func generate_code(annotations: Array) -> String:
	return "";