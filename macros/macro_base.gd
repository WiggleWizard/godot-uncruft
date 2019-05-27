extends Resource

const MACRO_SUFFIX     = "#@";
const MACRO_END_SUFFIX = "#@/";
const MACRO_INDICATOR  = MACRO_SUFFIX + "uncruft";
const MACRO_SUFFIX_SZ  = 2;


var command: String  = "";
var args: Dictionary = {};
var line: int        = -1;
var line_length: int = -1;

var expanded: bool   = false;
var end_line: int    = -1;


func expand() -> String:
	return "";

func format(s: String, extra_args: Dictionary={}) -> String:
	var combined_args = get_format_args();
	for key in extra_args:
		combined_args[key] = extra_args[key];
		
	return s.format(combined_args).strip_edges();
	
func get_format_args() -> Dictionary:
	var r = args.duplicate();
	r['line'] = line;
	return r;
	
func to_string():
	var expanded_str = "Expanded" if expanded else "Not expanded";
	return command + ": " + str(args) + " @ " + "L" + str(line) + " [" + expanded_str + "]";
	
func get_starting_line() -> int:
	return line;
	
func get_ending_line() -> int:
	return end_line;