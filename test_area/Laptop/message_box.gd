extends LineEdit

func _gui_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			$"../../../.."._on_send_pressed() 
			accept_event()
