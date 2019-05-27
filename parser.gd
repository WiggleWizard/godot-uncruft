extends Resource
const Macro = preload("macros/macro_base.gd");

var script_path = self.get_script().get_path().get_base_dir();


enum CursorMode {
	ExpectKey,
	ExpectValue
}

var _error = false;
var _last_error = "";

		
func parse_script(script: Script) -> Array:
	var macros = [];
	
	var curr_line_idx = 0;
	var curr_char_idx = 0;
	var curr_macro    = null;
	
	for line in script.source_code.split("\n"):
		if(is_macro_line(line)):
			var macro = parse_macro(line);
			if(macro == null):
				continue;
				
			macro.line = curr_line_idx;
			macros.append(macro);
			
			curr_macro = macro;
			
		# Hunting for the macro's ending
		elif(curr_macro != null && line.begins_with(Macro.MACRO_END_SUFFIX + curr_macro.command)):
			curr_macro.expanded = true;
			curr_macro.end_line = curr_line_idx;
			curr_macro = null;
			
		curr_line_idx += 1;
		curr_char_idx += line.length() + 1; # +1 for the line ending
	
	return macros;

func is_macro_line(line: String) -> bool:
	if(!line.begins_with(Macro.MACRO_END_SUFFIX) && line.begins_with(Macro.MACRO_SUFFIX) && !line.begins_with(Macro.MACRO_INDICATOR)):
		return true;
	return false;
	
func is_macro_end_line(line: String) -> bool:
	if(line.begins_with(Macro.MACRO_END_SUFFIX)):
		return true;
	return false;

func parse_macro(macro_line: String) -> Macro:
	if(is_macro_line(macro_line)):
		var command_end_idx = macro_line.find(" ");
		var has_args = true;
		
		var command_len = command_end_idx - Macro.MACRO_SUFFIX_SZ;
		if(command_end_idx == -1):
			command_len = macro_line.length() - Macro.MACRO_SUFFIX_SZ;
			has_args = false;
		
		var command = macro_line.substr(2, command_len);
		
		print(script_path);
		var macro = load(script_path + "/macros/" + command + ".gd").new();
		macro.command = command;
		if(has_args):
			macro.args = parse_args(macro_line.right(command_len + Macro.MACRO_SUFFIX_SZ + 1));
			
			if(_error):
				printerr(_last_error);
			else:
				return macro;
			
	return null;
	
func parse_args(args_raw: String) -> Dictionary:
	var result = {};
	
	var c_mode = CursorMode.ExpectKey;
	var curr_key = "";
	var in_quotes = false;
	var escape_next_char = false;
	
	for c in args_raw:
		# Building key string
		if(c_mode == CursorMode.ExpectKey):
			if(c == "="):
				c_mode = CursorMode.ExpectValue;
				result[curr_key] = "";
				continue;
			
			# Do not allow spaces in key
			if(c == " "):
				_set_error("Expected printable character, got space");
				break;
			curr_key += c;
			
		if(c_mode == CursorMode.ExpectValue):
			if(c == "\"" && !escape_next_char):
				in_quotes = !in_quotes;
				continue;
				
			if(c == " " && !in_quotes):
				c_mode = CursorMode.ExpectKey;
				curr_key = "";
				continue;
				
			if(escape_next_char):
				escape_next_char = false;
				
			if(c == "\\"):
				escape_next_char = true;
				continue;
				
			result[curr_key] += c;
		
	return result;
	
func _set_error(e: String):
	_error = true;
	_last_error = e;
	