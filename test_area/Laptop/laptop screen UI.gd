extends Control

var current_page = null
@onready var all_pages = $pages.get_children()
@onready var orders_page = $"pages/orders page"
@onready var database_page = $"pages/database page"
@onready var settings_page = $"pages/settings page"
@onready var chat_page = $"pages/chat page"


func _ready():
	switch_page(orders_page)

func switch_page(page):
	for element in all_pages:
		element.visible = false
	page.visible = true
	current_page = page

func _on_orders_button_pressed():
	switch_page(orders_page)

func _on_database_button_pressed():
	switch_page(database_page)

func _on_settings_button_pressed():
	switch_page(settings_page)
