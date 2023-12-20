class_name GuideBook
extends Node2D


signal guide_book_closed


var guide_page_cursor = 0
var guide_pages = []


const guide_page_paths = [
	"res://scenes/game_guide/guide_pages/game_objectives_page.tscn",
	"res://scenes/game_guide/guide_pages/game_controls_page.tscn",
	"res://scenes/game_guide/guide_pages/need_a_break_page.tscn",
]

# Called when the node enters the scene tree for the first time.
func _ready():
	init_pages()
	if guide_pages.size() > 0:
		guide_pages[0].show()
		$CurrentPage.text = str(guide_page_cursor + 1)
		$MaxPage.text = str(guide_pages.size())
	else:
		$CurrentPage.hide()
		$PageSlash.hide()
		$CloseButton.hide()
		$LeftButton.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func init_pages():
	for page_path in guide_page_paths:
		var guide_page = load(page_path).instantiate()
		guide_page.hide()
		guide_pages.append(guide_page)
		$GuidePageDisplayLayer.add_child(guide_page)


func look_left():
	guide_pages[guide_page_cursor].hide()
	guide_page_cursor -= 1
	if guide_page_cursor < 0: guide_page_cursor = guide_pages.size() - 1
	guide_pages[guide_page_cursor].show()
	$CurrentPage.text = str(guide_page_cursor + 1)


func look_right():
	guide_pages[guide_page_cursor].hide()
	guide_page_cursor += 1
	if guide_page_cursor >= guide_pages.size(): guide_page_cursor = 0
	guide_pages[guide_page_cursor].show()
	$CurrentPage.text = str(guide_page_cursor + 1)


func _on_close_button_pressed():
	guide_book_closed.emit()
	queue_free()


func _on_left_button_pressed():
	look_left()


func _on_right_button_pressed():
	look_right()
