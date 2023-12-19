class_name GoonGallery
extends Node2D


signal goon_gallery_closed


var goon_page_cursor = 0
var goon_pages = []


const goon_page_paths = [
	"res://scenes/goon_gallery/goon_pages/dizzy_mole_page.tscn",
	"res://scenes/goon_gallery/goon_pages/fighty_lobster_page.tscn",
]


# Called when the node enters the scene tree for the first time.
func _ready():
	init_pages()
	if goon_pages.size() > 0: goon_pages[0].show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func init_pages():
	for page_path in goon_page_paths:
		var goon_page = load(page_path).instantiate()
		goon_page.hide()
		goon_pages.append(goon_page)
		$GoonPageDisplayLayer.add_child(goon_page)


func _on_close_button_pressed():
	goon_gallery_closed.emit()
	queue_free()


func look_left():
	goon_pages[goon_page_cursor].hide()
	goon_page_cursor -= 1
	if goon_page_cursor < 0: goon_page_cursor = goon_pages.size() - 1
	goon_pages[goon_page_cursor].show()


func look_right():
	goon_pages[goon_page_cursor].hide()
	goon_page_cursor += 1
	if goon_page_cursor >= goon_pages.size(): goon_page_cursor = 0
	goon_pages[goon_page_cursor].show()


func _on_left_button_pressed():
	look_left()


func _on_right_button_pressed():
	look_right()
