;	--- Settings ---
var $crafter_count = 1
var $container_count = 1

var $H2_tank_count = 1
var $H2O_tank_count = 1
var $CH4_tank_count = 1
var $CO2_tank_count = 1
var $N_tank_count = 1
var $O2_tank_count = 1

var $H2_tank_volume = 14
var $H2O_tank_volume = 14
var $CH4_tank_volume = 14
var $CO2_tank_volume = 14
var $N_tank_volume = 14
var $O2_tank_volume = 14

; Text and Button Sizes
var $text_size = 2
var $scroll_speed = 3
var $button_padding = 4

; Button Colors
var $default_border_color = black
var $default_fill_color = gray
var $default_text_color = white

var $selected_border_color = green
var $selected_fill_color = gray
var $selected_text_color = white

var $warning_border_color = red
var $warning_fill_color = gray
var $warning_text_color = white
;	--- Settings ---

;	--- Variables ---
; General Global
array $category_list :text

array $item_pre_queue :text
array $quantity_pre_queue :number

storage array $item_queue :text
storage array $quantity_queue :number

var $pre_queued_resources = ""
var $queued_resources = ""
var $inventory_resources = ""

var $crafter_progress = 0

; General Draw
var $screen = screen("Crafting Screen", 0)

var $button_w :number
var $button_h :number
var $screen_w :number
var $screen_h :number

var $d_color = ""
var $s_color = ""
var $w_color = ""

var $current_line :number
var $current_tab = "Crafting"
var $scroll_offset = 0
var $scroll_limit = 0

; Crafting Draw
var $crafting_button_x :number
var $crafting_button_w :number

var $current_category :text

var $selected_craft = "None"
var $is_craftable = 0
var $craft_quantity = 1

; Storage Draw
array $resource_list :text  

;	--- Helper Functions ---
; Draw Functions
function @labled_button($x :number, $y :number, $width :number, $height :number, $label :text, $border_color :number, $fill_color :number, $text_color :number, $label_offset_x :number, $label_offset_y :number) :number
	array $line_list :text
	$line_list.from($label, "\n")
	var $line_amount = size($line_list)

	var $start_x = $x - $width/2
	var $end_x = $x + $width/2
	var $start_y = $y - $height/2
	var $end_y = $y + $height/2

	var $pressed = $screen.button_rect($start_x, $start_y, $end_x, $end_y, $border_color, $fill_color)
	
	foreach $line_list ($line_number, $line_text)
		var $line_x = $x - $screen.char_w*size($line_text)/2 + $label_offset_x + 1
		var $line_y = $y + $screen.char_h*($line_number - $line_amount/2) + $label_offset_y + 1

		$screen.write($line_x, $line_y, $text_color, $line_text)
	
	return $pressed

function @scroll_buttons($x :number, $y :number, $width :number, $height :number, $parts :number, $offset :number, $speed :number, $limit :number) :number
	var $part_h = $height/$parts

	if @labled_button($x, $y-$part_h/2*($parts + 1)/2, $width, $part_h*($parts - 1)/2, "+", $d_color.border, $d_color.fill, $d_color.text)
		$offset += $speed
	if @labled_button($x, $y, $width, $part_h, "0", $d_color.border, $d_color.fill, $d_color.text)
		$offset = 0
	if @labled_button($x, $y+$part_h/2*($parts + 1)/2, $width, $part_h*($parts - 1)/2, "-", $d_color.border, $d_color.fill, $d_color.text)
		$offset -= $speed

	if $limit >= 0
		$offset = 0
	else
		$offset = clamp($offset, $limit, 0)

	return $offset

function @tab_buttons($x :number, $y :number, $width :number, $height :number, $tabs :text, $y_tab :text) :text
	array $tab_list :text
	$tab_list.from($tabs, ", ")
	var $tab_w = $width/$tab_list.size

	foreach $tab_list ($i, $tab)
		var $pressed = 0
		var $tab_x = $x+($tab_w*(1+2*$i)-$width)/2
		if $tab == $y_tab
			$pressed = @labled_button($tab_x, $y, $tab_w, $height, $tab, $s_color.border, $s_color.fill, $s_color.text)
		else
			$pressed = @labled_button($tab_x, $y, $tab_w, $height,  $tab, $d_color.border, $d_color.fill, $d_color.text)
		if $pressed
			$y_tab = $tab
	return $y_tab

function @quantity_buttons($x :number, $y :number, $width :number, $height :number, $labels :text, $current_quantity :number) :number
	array $label_list :text
	$label_list.from($labels, ", ")
	var $lable_count = $label_list.size
	var $label_h = $height/$lable_count

	foreach $label_list ($i, $label)
		var $label_y = $y+($label_h*(1+2*$i)-$height)/2
		if @labled_button($x, $label_y, $width, $label_h, $label, $d_color.border, $d_color.fill, $d_color.text)
			if $i < $lable_count/2 - 0.5
				$current_quantity += 10^(round($lable_count/2-1)-$i)
			elseif $i == $lable_count/2 - 0.5
				$current_quantity = 1
			else
				$current_quantity -= 10^($i-round($lable_count/2))

	if $current_quantity < 1
		$current_quantity = 1
	return $current_quantity
; Queue Functions
function @get_category($item :text) :text
	foreach $category_list ($i, $category)
		array $category_items :text
		$category_items.from(get_recipes("crafter", $category), ",")
		foreach $category_items ($j, $category_item)
			if $category_item == $item
				return $category
	return ""
function @pre_queue_craft($craft :text)
	$item_pre_queue.clear()
	$quantity_pre_queue.clear()
	$pre_queued_resources = ""

	$item_pre_queue.append($craft)
	$quantity_pre_queue.append(1)

	var $i = 0
	while $i != $item_pre_queue.size
		var $ingridients = get_recipe("crafter", @get_category($item_pre_queue.$i), $item_pre_queue.$i)
		foreach $ingridients ($ingridient, $amount)
			if @get_category($ingridient) != ""
				$item_pre_queue.append($ingridient)
				$quantity_pre_queue.append($quantity_pre_queue.$i*$amount)
			else
				$pre_queued_resources.$ingridient += $amount
		$i += 1

	$i = 0
	while $i < $item_pre_queue.size
		var $j = 0
		while $j < $item_pre_queue.size-1-$i
			var $k = $item_pre_queue.size-1-$i
			if $item_pre_queue.$j == $item_pre_queue.$k
				$quantity_pre_queue.$k += $quantity_pre_queue.$j
				$item_pre_queue.erase($j)
				$quantity_pre_queue.erase($j)
			else
				$j += 1
		$i += 1
function @queue_craft($quantity :number)
	while $item_pre_queue.size != 0
		$item_queue.append($item_pre_queue.last)
		$quantity_queue.append($quantity_pre_queue.last*$quantity)
		$item_pre_queue.pop()
		$quantity_pre_queue.pop()
	$selected_craft = "None"
	$pre_queued_resources = ""
; Inventory Functions
function @get_container_inventory($inventory_count :number)
	var $contents = ""
	var $i = 1

	while $i <= $inventory_count
		$contents = input_text("Container " & $i :text, 0)
		foreach $contents ($item, $amount)
			$inventory_resources.$item += $amount
		$i += 1
function @get_tank_inventory($tank_type :text, $inventory_count :number, $tank_volume :number)
	var $fill_level = 0
	var $i = 1
	while $i <= $inventory_count
		$fill_level += input_number($tank_type & " Tank " & $i :text, 0)
		$i += 1

	var $density = 0
	if $tank_type == "H2"
		$density = 100
	elseif $tank_type == "H2O"
		$density = 1000
	elseif $tank_type == "CH4"
		$density = 400
	elseif $tank_type == "CO2"
		$density = 1
	elseif $tank_type == "N"
		$density = 1
	elseif $tank_type == "O2"
		$density = 1600

	$inventory_resources.$tank_type = $fill_level*$tank_volume*$density

function @get_all_inventories()
	$inventory_resources = ""
	@get_container_inventory($container_count)
	@get_tank_inventory("H2", $H2_tank_count, $H2_tank_volume)
	@get_tank_inventory("H2O", $H2O_tank_count, $H2O_tank_volume)
	@get_tank_inventory("CH4", $CH4_tank_count, $CH4_tank_volume)
	@get_tank_inventory("CO2", $CO2_tank_count, $CO2_tank_volume)
	@get_tank_inventory("N", $N_tank_count, $N_tank_volume)
	@get_tank_inventory("O2", $O2_tank_count, $O2_tank_volume)
function @get_item_resources($item :text) :text
	var $resources = ""
	var $ingridients = get_recipe("crafter", @get_category($item), $item)

	foreach $ingridients ($ingridient, $amount)
		if @get_category($ingridient) == ""
			$resources.$ingridient += $amount
	return $resources
function @get_queued_resources()
	$queued_resources = ""
	foreach $item_queue ($i, $item)
		var $item_resources = @get_item_resources($item)
		foreach $item_resources ($item_resource, $amount)
			$queued_resources.$item_resource += $amount*$quantity_queue.$i
; Storage Functions
function @scientific_format($number :number) :text
	var $number_text = text("{0e.00}", $number)
	var $leading_digits = substring($number_text, 0, find($number_text, "e"))
	var $exponent = substring($number_text, find($number_text, "e")+1, size($number_text))
	var $suffix = ""
	var $is_positive = 1

	if $exponent < 0
		$is_positive = 0

	if floor($exponent/3) == 1
		$suffix = "k"
	elseif floor($exponent/3) == -1
		$suffix = "m"
	elseif floor($exponent/3) == 2
		$suffix = "M"
	elseif floor($exponent/3) == -2
		$suffix = "u"
	elseif floor($exponent/3) == 3
		$suffix = "G"
	elseif floor($exponent/3) == -3
		$suffix = "n"
	elseif floor($exponent/3) == 4
		$suffix = "T"
	elseif floor($exponent/3) == -4
		$suffix = "p"
	elseif floor($exponent/3) == 5
		$suffix = "P"
	elseif floor($exponent/3) == -5
		$suffix = "f"
	elseif floor($exponent/3) == 6
		$suffix = "E"
	elseif floor($exponent/3) == -6
		$suffix = "a"
	elseif floor($exponent/3) == 7
		$suffix = "Z"
	elseif floor($exponent/3) == -7
		$suffix = "z"
	elseif floor($exponent/3) == 8
		$suffix = "Y"
	elseif floor($exponent/3) == -8
		$suffix = "y"
	elseif floor($exponent/3) == 9
		$suffix = "R"
	elseif floor($exponent/3) == -9
		$suffix = "r"
	elseif floor($exponent/3) == 10
		$suffix = "Q"
	elseif floor($exponent/3) == -10
		$suffix = "q"

	if $is_positive
		return text("{}{}", $leading_digits*(10^($exponent%3)), $suffix)
	else
		return text("{}{}", $leading_digits*(10^((3+$exponent%3)%3)), $suffix)
function @element_name($element :text) :text
	var $name = $element

	if $element == "C"
		$name = "Carbon"
	elseif $element == "Al"
		$name = "Aluminium"
	elseif $element == "Si"
		$name = "Silicon"
	elseif $element == "Ti"
		$name = "Titanium"
	elseif $element == "Cr"
		$name = "Chrome"
	elseif $element == "Fe"
		$name = "Iron"
	elseif $element == "Ni"
		$name = "Nickel"
	elseif $element == "Cu"
		$name = "Copper"
	elseif $element == "Ag"
		$name = "Silver"
	elseif $element == "Sn"
		$name = "Tin"
	elseif $element == "W"
		$name = "Tungsten"
	elseif $element == "Au"
		$name = "Gold"
	elseif $element == "Pb"
		$name = "Lead"
	elseif $element == "U"
		$name = "Uranium"

	return $name
function @draw_recource_line($y :number, $resource :text, $pre_queued :text, $queued :text, $avalible :text, $color :number)
	var $invis = color(0, 0, 0, 0)

	$screen.write($screen_w*1/4-$screen.char_w/2, $y, $color, ":")
	$screen.write($screen_w*2/4-$screen.char_w/2, $y, $color, "|")
	$screen.write($screen_w*3/4-$screen.char_w/2, $y, $color, "|")

	@labled_button($screen_w*1/8, $y+$screen.char_h/2, 0, 0, $resource, $invis, $invis, $color)
	@labled_button($screen_w*3/8, $y+$screen.char_h/2, 0, 0, $pre_queued, $invis, $invis, $color)
	@labled_button($screen_w*5/8, $y+$screen.char_h/2, 0, 0, $queued, $invis, $invis, $color)
	@labled_button($screen_w*7/8, $y+$screen.char_h/2, 0, 0, $avalible, $invis, $invis, $color)
;	--- Helper Functions ---

;	--- Main Functions ---
function @init_screen()
	$screen.text_size($text_size)

	$button_h = $screen.char_h+$button_padding
	$button_w = $screen.char_w+$button_padding
	$screen_h = $screen.height-$button_h
	$screen_w = $screen.width-$button_w

	$d_color.border = $default_border_color
	$d_color.fill = $default_fill_color
	$d_color.text = $default_text_color

	$s_color.border = $selected_border_color
	$s_color.fill = $selected_fill_color
	$s_color.text = $selected_text_color

	$w_color.border = $warning_border_color
	$w_color.fill = $warning_fill_color
	$w_color.text = $warning_text_color

	$crafting_button_x = ($screen_w-$button_w)/2
	$crafting_button_w = $screen_w-$button_w

	$current_category = "None"

function @update_screen()
	$screen.blank(black)
	$screen.text_size($text_size)
	$current_line = 1.5 + $scroll_offset
	
	if $current_tab == "Crafting"
		foreach $category_list ($i, $category)
			if @labled_button($crafting_button_x, $button_h*$current_line, $crafting_button_w, $button_h, $category, $d_color.border, $d_color.fill, $d_color.text) and $current_line >= 1.5 and $current_line < $screen_h/$button_h + 0.5
				$selected_craft = "None"
				$pre_queued_resources = ""
				if $current_category != $category
					$current_category = $category
				else
					$current_category = "None"
			$current_line += 1
			if $current_category == $category
				array $category_items : text
				$category_items.from(get_recipes("crafter", $category), ",")
				foreach $category_items ($j, $category_item)
					var $border_color = $d_color.border
					var $fill_color = $d_color.fill
					var $text_color = $d_color.text
					if $category_item == $selected_craft
						$is_craftable = 1
						$border_color = $s_color.border
						$fill_color = $s_color.fill
						$text_color = $s_color.text
						foreach $pre_queued_resources ($resource, $amount)
							if $amount*$craft_quantity > $inventory_resources.$resource - $queued_resources.$resource
								$is_craftable = 0
								$border_color = $w_color.border
								$fill_color = $w_color.fill
								$text_color = $w_color.text	
					if @labled_button($crafting_button_x, $button_h*$current_line, $crafting_button_w-3*$button_padding, $button_h, $category_item, $border_color, $fill_color, $text_color) and $current_line >= 1.5 and $current_line < $screen_h/$button_h + 0.5
						if $category_item == $selected_craft
							$selected_craft = "None"
							$pre_queued_resources = ""
						else
							$selected_craft = $category_item
							@pre_queue_craft($category_item)
					$current_line += 1
	
		$craft_quantity = @quantity_buttons($screen_w-$button_w/2, $button_h+$screen_h/2, $button_w, $screen_h, "+\nk, +\nh, +\nd, +, -, -\nd, -\nh, -\nk", $craft_quantity, $d_color.border, $d_color.fill, $d_color.text)
		if $selected_craft == "None"
			@labled_button($crafting_button_x, $screen.height-$button_h/2, $crafting_button_w, $button_h, "Craft " & $craft_quantity : text & "x", $d_color.border, $d_color.fill, $d_color.text)
		elseif $is_craftable
			if @labled_button($crafting_button_x, $screen.height-$button_h/2, $crafting_button_w, $button_h, "Craft " & $craft_quantity : text & "x", $s_color.border, $s_color.fill, $s_color.text)
				@queue_craft($craft_quantity)
				$selected_craft = "None"
				$craft_quantity = 1
		else
			@labled_button($crafting_button_x, $screen.height-$button_h/2, $crafting_button_w, $button_h, "Craft " & $craft_quantity : text & "x", $w_color.border, $w_color.fill, $w_color.text)
	if $current_tab == "Queue"
		foreach $item_queue ($i, $item)
			var $remaining_items = $quantity_queue.$i-$inventory_resources.$item
			var $completion = $inventory_resources.$item/$quantity_queue.$i
			if $i == 0
				$completion += $crafter_progress/$quantity_queue.$i

			$screen.draw_rect(0, $button_h*($current_line-0.5), $screen_w*$completion, $button_h*($current_line+0.5), $d_color.border :number, $d_color.fill :number)
			$screen.write($button_padding, $button_h*($current_line-0.5)+$button_padding, $d_color.text :number, $remaining_items :text & "x " & $item)
			$current_line += 1

	if $current_tab == "Storage"
		$resource_list.from("H2, H2O, C, CH4, CO2, N, O2, Al, Si, Ti, Cr, Fe, Ni, Cu, Ag, Sn, W, Au, Pb, U", ", ")

		foreach $resource_list ($i, $resource)
			var $resource_name = @element_name($resource)
			var $pre_queued =  @scientific_format($pre_queued_resources.$resource_name*$craft_quantity)
			var $queued =  @scientific_format($queued_resources.$resource_name)
			var $avalible = @scientific_format($inventory_resources.$resource_name-$queued_resources.$resource_name)

			var $color = $s_color.text
			if $inventory_resources.$resource_name < $queued_resources.$resource_name
				$color = $w_color.text
			elseif $pre_queued_resources.$resource_name*$craft_quantity > $inventory_resources.$resource_name-$queued_resources.$resource_name
				$color = $d_color.text

			@draw_recource_line($button_h*($current_line-0.5)+$button_padding, $resource, $pre_queued, $queued, $avalible, $color)
			
			$current_line += 1
			
	$current_tab = @tab_buttons($screen.width/2, $button_h/2, $screen.width, $button_h, "Crafting, Queue, Storage", $current_tab)
	$scroll_offset = @scroll_buttons($screen_w+$button_w/2, $button_h+$screen_h/2, $button_w, $screen_h, 8, $scroll_offset, $scroll_speed, $scroll_limit)
	$scroll_limit = $screen_h/$button_h-($current_line-$scroll_offset) + 0.5
function @update_resources()
	@get_all_inventories()
	@get_queued_resources()
function @crafting_loop()
	$crafter_progress = 0
	var $active_crafters = 0
	var $i = 1
	while $i <= $crafter_count
		var $progress = input_number("Crafter " & $i :text, 0)
		$crafter_progress += $progress
		if abs($progress) != 1 and $progress != 0
			$active_crafters += 1
		$i += 1
	
	if $item_queue.size != 0
		var $current_craft = $item_queue.0
		$i = 1
		while $i <= $crafter_count
			var $progress = input_number("Crafter " & $i :text, 0)
			if ($quantity_queue.0 > $active_crafters + $inventory_resources.$current_craft) and (abs($progress) == 1 or $progress == 0)
				output_text("Crafter " & $i :text, 1, $current_craft)
				output_number("Crafter " & $i :text, 0, 1)
				output_number("Crafter " & $i :text, 0, 0)
				$active_crafters += 1
			$i += 1

	if $quantity_queue.0 <= $inventory_resources.$current_craft
			$item_queue.erase(0)
			$quantity_queue.erase(0)
			$i = 1
			while $i <= $crafter_count
				output_text("Crafter " & $i :text, 1, "None")
				$i += 1
;	--- Main Functions ---

;	--- Main ---
init
	$category_list.from(get_recipes_categories("crafter"), ",")
	@init_screen()
	
tick
	@update_screen()
	@update_resources()
	@crafting_loop()
;	--- Main ---