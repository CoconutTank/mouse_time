class_name GuideBook
extends Node2D


# Tracks the current page of the guide book that is being viewed.
var guide_page_cursor = 0


# Array containing the instantiated guide book pages.
var guide_pages = []


# Internal paths to the scenes for each individual page in the guide book.
const guide_page_paths = [
	"res://scenes/game_guide/guide_pages/game_objectives_page.tscn",
	"res://scenes/game_guide/guide_pages/game_controls_page.tscn",
	"res://scenes/game_guide/guide_pages/need_a_break_page.tscn",
]

# Called when the node enters the scene tree for the first time.
# There'll be a call to init_pages to try and fill in the pages. If
# initialization is successful, the guide book will start on the first page
# and fill in the page numbers on screen.
func _ready():
	init_pages()
	if guide_pages.size() > 0:
		guide_pages[0].show()
		$CurrentPage.text = str(guide_page_cursor + 1)
		$MaxPage.text = str(guide_pages.size())
	else:
		$CurrentPage.hide()
		$PageSlash.hide()
		$MaxPage.hide()
		$RightButton.hide()
		$LeftButton.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Treats each entry in guide_page_paths as a path to a page to be used in this
# guide book. Each instantiated page is first hidden, then added to the 
# guide pages array for tracking, and to the GuidePageDisplayLayer for
# drawing later.
func init_pages():
	for page_path in guide_page_paths:
		var guide_page = load(page_path).instantiate()
		guide_page.hide()
		guide_pages.append(guide_page)
		$GuidePageDisplayLayer.add_child(guide_page)


# Flips the guide book to the previous page. If guide_page_cursor becomes
# less than 0, it'll wrap around to the last viable page of the guide book.
func look_left():
	guide_pages[guide_page_cursor].hide()
	guide_page_cursor -= 1
	if guide_page_cursor < 0: guide_page_cursor = guide_pages.size() - 1
	guide_pages[guide_page_cursor].show()
	$CurrentPage.text = str(guide_page_cursor + 1)


# Flips the guide book to the next page. If guide_page_cursor exceeds the
# available pages of the guide book, it'll wrap around to the first page.
func look_right():
	guide_pages[guide_page_cursor].hide()
	guide_page_cursor += 1
	if guide_page_cursor >= guide_pages.size(): guide_page_cursor = 0
	guide_pages[guide_page_cursor].show()
	$CurrentPage.text = str(guide_page_cursor + 1)


# Function tied to the close button being pressed.
func _on_close_button_pressed():
	queue_free()


# Function tied to the left button being pressed.
func _on_left_button_pressed():
	look_left()


# Function tied to the right button being pressed.
func _on_right_button_pressed():
	look_right()
