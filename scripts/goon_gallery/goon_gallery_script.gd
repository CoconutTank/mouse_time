class_name GoonGallery
extends Node2D


# Tracks the current page of the goon gallery that is being viewed.
var goon_page_cursor = 0


# Array containing the instantiated goon gallery pages.
var goon_pages = []


# Internal paths to the scenes for each individual page in the goon gallery.
const goon_page_paths = [
	"res://scenes/goon_gallery/goon_pages/dizzy_mole_page.tscn",
	"res://scenes/goon_gallery/goon_pages/fighty_lobster_page.tscn",
]


# Called when the node enters the scene tree for the first time.
# There'll be a call to init_pages to try and fill in the pages. If
# initialization is successful, the goon gallery will start on the first page
# and fill in the page numbers on screen.
func _ready():
	init_pages()
	if goon_pages.size() > 0:
		goon_pages[goon_page_cursor].show()
		$CurrentPage.text = str(goon_page_cursor + 1)
		$MaxPage.text = str(goon_pages.size())
	else:
		$CurrentPage.hide()
		$PageSlash.hide()
		$MaxPage.hide()
		$RightButton.hide()
		$LeftButton.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Treats each entry in goon_page_paths as a path to a page to be used in this
# goon gallery. Each instantiated page is first hidden, then added to the 
# goon pages array for tracking, and to the GoonPageDisplayLayer for
# drawing later.
func init_pages():
	for page_path in goon_page_paths:
		var goon_page = load(page_path).instantiate()
		goon_page.hide()
		goon_pages.append(goon_page)
		$GoonPageDisplayLayer.add_child(goon_page)


# Flips the goon gallery to the previous page. If goon_page_cursor becomes
# less than 0, it'll wrap around to the last viable page of the goon gallery.
func look_left():
	goon_pages[goon_page_cursor].hide()
	goon_page_cursor -= 1
	if goon_page_cursor < 0: goon_page_cursor = goon_pages.size() - 1
	goon_pages[goon_page_cursor].show()
	$CurrentPage.text = str(goon_page_cursor + 1)


# Flips the goon gallery to the next page. If goon_page_cursor exceeds the
# available pages of the goon gallery, it'll wrap around to the first page.
func look_right():
	goon_pages[goon_page_cursor].hide()
	goon_page_cursor += 1
	if goon_page_cursor >= goon_pages.size(): goon_page_cursor = 0
	goon_pages[goon_page_cursor].show()
	$CurrentPage.text = str(goon_page_cursor + 1)


# Function tied to the close button being pressed.
func _on_close_button_pressed():
	queue_free()


# Function tied to the left button being pressed.
func _on_left_button_pressed():
	look_left()


# Function tied to the right button being pressed.
func _on_right_button_pressed():
	look_right()
