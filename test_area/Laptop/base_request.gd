extends VBoxContainer

@onready var request_name = $"request head/HBoxContainer/Request name"
@onready var customer_name = $"request body/VBoxContainer/Customer name"
@onready var reward_text = $"request body/VBoxContainer/Reward"
@onready var description_text = $"request body/VBoxContainer/Description"
@onready var request_body = $"request body"
var active_texture = load("res://test_area/Laptop/temp requst accepted.png")
var inactive_texture = load("res://test_area/Laptop/temp requst state.png")
var contract
var requestData
var is_request_open = false
var is_active = false

# Called when the node enters the scene tree for the first time.
#func _ready():
	#contract = ContractManager.rng_contract()
	#request_name.text = contract.name
	#customer_name.text = 'Customer: ' + contract.customer
	#reward_text.text = 'Price: ' + contract.price
	#description_text.text = contract.desc


func toggle_request_window():
	if is_request_open:
		is_request_open = false
		request_body.visible = false
	else:
		is_request_open = true
		request_body.visible = true
		
#func _on_accept_btn_button_up():
	#if ContractManager.accept_contract(contract):
		#print('Accepted contract')
		#is_active = true
		#$"request head/HBoxContainer/Request state".texture = active_texture
	#else:
		#pass
#
#
#func _on_reject_btn_button_up():
	#if is_active:
		#$"request head/HBoxContainer/Request state".texture = inactive_texture
		#ContractManager.forfeit_contract(contract.id)
		#is_active = false
	#else:
		#$"..".visible = false


func _on_request_window_btn_button_up():
	toggle_request_window()
	pass # Replace with function body.
