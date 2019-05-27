tool
extends EditorPlugin

var _menu_button = null;

enum MenuPopupIndices {
	PREPROCESS_CURRENT_SCRIPT,
	PREPROCESS_ALL_OPEN_SCRIPTS,
	PREPROCESS_ALL_SCRIPTS,
	CLEAR_CURRENT_SCRIPT
};


func _enter_tree():
	_configure_settings();

	var editor_interface = get_editor_interface();
	var script_editor    = editor_interface.get_script_editor();
	
	var menu = script_editor.get_children()[0].get_children()[0];
	for menu_child in menu.get_children():
		if(menu_child is MenuButton and menu_child.text == "Debug"):
			_menu_button = MenuButton.new();
			menu.add_child_below_node(menu_child, _menu_button);

			_configure_menu();

func _exit_tree():
	if(_menu_button != null):
		_menu_button.get_parent().remove_child(_menu_button);
		_menu_button.queue_free();
	
func _on_item_pressed(idx: int):
	if(idx == MenuPopupIndices.PREPROCESS_CURRENT_SCRIPT):
		var editor_interface = get_editor_interface();
		var script_editor    = editor_interface.get_script_editor();
		
		var script = script_editor.get_current_script();
		var preprocessor = preload("preprocessor.gd").new(script);
		preprocessor.expand_macros();
		
		script_editor._reload_scripts();
	elif(idx == MenuPopupIndices.CLEAR_CURRENT_SCRIPT):
		var editor_interface = get_editor_interface();
		var script_editor    = editor_interface.get_script_editor();
		
		var script = script_editor.get_current_script();
		var preprocessor = preload("preprocessor.gd").new(script);
		preprocessor.clear_expanded_macros();
		
		script_editor._reload_scripts();
		

func _configure_menu():
	_menu_button.text = "Uncruft";

	var popup = _menu_button.get_popup();
	popup.add_item("Expand macros in current script", MenuPopupIndices.PREPROCESS_CURRENT_SCRIPT);
	popup.add_item("Clear expanded macres", MenuPopupIndices.CLEAR_CURRENT_SCRIPT);
	popup.connect("id_pressed", self, "_on_item_pressed");

func _configure_settings():
	# Setup Uncruft settings in Project Config
	_configure_setting("uncruft", "macros/custom_macro_path", TYPE_STRING, "res://macros", PROPERTY_HINT_DIR);
	_configure_setting("uncruft", "expansion/tab_type", TYPE_INT, "Tabs,Spaces", PROPERTY_HINT_ENUM);
	_configure_setting("uncruft", "expansion/tab_size", TYPE_INT, 4);

func _configure_setting(section: String, key: String, type, default, hint=PROPERTY_HINT_NONE, hint_string=null):
	var full_key_path = section + "/" + key;

	if(!ProjectSettings.has_setting(full_key_path)):
		ProjectSettings.set_setting(full_key_path, default);
		
	var property_info = {
		"name": full_key_path,
		"type": type,
		"hint": hint,
		"hint_string": default
	}
	ProjectSettings.add_property_info(property_info);
	ProjectSettings.set_initial_value(full_key_path, default);