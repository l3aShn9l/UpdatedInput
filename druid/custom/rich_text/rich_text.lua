-- Copyright (c) 2022 Maksim Tuprikov <insality@gmail.com>. This code is licensed under MIT license

--- Druid Rich Text Custom Component.
-- <b># Overview #</b>
--
-- This custom component is inspired by <a href="https://github.com/britzl/defold-richtext" target="_blank">defold-richtext</a> by britzl.
-- It uses a similar syntax for tags but currently supports fewer tags.
--
-- All parameters for the Rich Text component are adjusted in the GUI scene.
--
-- This component uses GUI component template. (/druid/custom/rich_text/rich_text.gui).
--
-- You able to customize it or make your own with the next node scructure:
--
-- root
--
--   - text_prefab
--
--   - icon_prefab
--
-- <b># Rich Text Setup #</b>
--
-- • Root node size: Set the maximum width and height of the text.
--
-- • Root anchor: Define the alignment of the Rich Text inside the root node size area.
--
-- • Text prefab: Configure all default text parameters for the text node.
--
-- • Text prefab anchor: Set the anchor for each text node (adjust this only if animating text).
--
-- • Icon prefab: Configure all default node parameters for the icon node.
--
-- • Icon prefab anchor: Set the anchor for each icon node (adjust this only if animating the icon).
--
-- <b># Notes #</b>
--
-- • Nested tags are supported
--
-- <a href="https://insality.github.io/druid/druid/index.html?example=custom_rich_text" target="_blank"><b>Example Link</b></a>
-- @usage
-- local RichText = require("druid.custom.rich_text.rich_text")
-- ...
-- self.rich_text = self.druid:new(RichText, "rich_text")
-- self.rich_text:set_text("Hello, Druid Rich Text!")
-- @usage
-- type druid.rich_text.word = {
--   node: Node,
--   relative_scale: number,
--   color: vector4,
--   position: vector3,
--   offset: vector3,
--   scale: vector3,
--   size: vector3,
--   metrics: druid.rich_text.metrics,
--   pivot: Pivot,
--   text: string,
--   shadow: vector4,
--   outline: vector4,
--   font: string,
--   image: druid.rich_text.image,
--   default_animation: string,
--   br: boolean,
--   nobr: boolean,
-- }
--
-- type druid.rich_text.word.image = {
--   texture: string,
--   anim: string,
--   width: number,
--   height: number,
-- }
--
-- type druid.rich_text.lines_metrics = {
--   text_width: number,
--   text_height: number,
--   lines: table<number, druid.rich_text.metrics>,
-- }
--
-- type druid.rich_text.metrics = {
--   width: number,
--   height: number,
--   offset_x: number|nil,
--   offset_y: number|nil,
--   node_size: vector3|nil @For images only,
-- }
-- @module RichText
-- @within BaseComponent
-- @alias druid.rich_text

--- The component druid instance
-- @tfield DruidInstance druid @{DruidInstance}


local component = require("druid.component")
local rich_text = require("druid.custom.rich_text.module.rt")

local RichText = component.create("rich_text")

local SCHEME = {
	ROOT = "root",
	TEXT_PREFAB = "text_prefab",
	ICON_PREFAB = "icon_prefab"
}


--- Rich Text component constructor
-- @tparam RichText self @{RichText}
-- @tparam string template The Rich Text template name
-- @tparam table nodes The node table, if prefab was copied by gui.clone_tree()
function RichText.init(self, template, nodes)
	self:set_template(template)
	self:set_nodes(nodes)

	self.root = self:get_node(SCHEME.ROOT)
	self.druid = self:get_druid()

	self.text_prefab = self:get_node(SCHEME.TEXT_PREFAB)
	self.icon_prefab = self:get_node(SCHEME.ICON_PREFAB)

	gui.set_enabled(self.text_prefab, false)
	gui.set_enabled(self.icon_prefab, false)

	self._settings = self:_create_settings()
end


--- Component style params.
-- You can override this component styles params in Druid styles table
-- or create your own style
-- @table style
-- @tfield[opt={}] table COLORS Rich Text color aliases
-- @tfield[opt=20] number ADJUST_STEPS Amount steps of attemps text adjust by height
-- @tfield[opt=0.02] number ADJUST_SCALE_DELTA Scale step on each height adjust step
function RichText.on_style_change(self, style)
	self.style = {}
	self.style.COLORS = style.COLORS or {}
	self.style.ADJUST_STEPS = style.ADJUST_STEPS or 20
	self.style.ADJUST_SCALE_DELTA = style.ADJUST_SCALE_DELTA or 0.02
end


--- Set text for Rich Text
-- @tparam RichText self @{RichText}
-- @tparam string text The text to set
-- @treturn druid.rich_text.word[] words
-- @treturn druid.rich_text.lines_metrics line_metrics
-- @usage
-- • color: Change text color
--
-- <color=red>Foobar</color>
-- <color=1.0,0,0,1.0>Foobar</color>
-- <color=#ff0000>Foobar</color>
-- <color=#ff0000ff>Foobar</color>
--
-- • shadow: Change text shadow
--
-- <shadow=red>Foobar</shadow>
-- <shadow=1.0,0,0,1.0>Foobar</shadow>
-- <shadow=#ff0000>Foobar</shadow>
-- <shadow=#ff0000ff>Foobar</shadow>
--
-- • outline: Change text shadow
--
-- <outline=red>Foobar</outline>
-- <outline=1.0,0,0,1.0>Foobar</outline>
-- <outline=#ff0000>Foobar</outline>
-- <outline=#ff0000ff>Foobar</outline>
--
-- • font: Change font
--
-- <font=MyCoolFont>Foobar</font>
--
-- • size: Change text size, relative to default size
--
-- <size=2>Twice as large</size>
--
-- • br: Insert a line break
--
-- <br/>
--
-- • nobr: Prevent the text from breaking
--
-- Words <nobr>inside tag</nobr> won't break
--
-- • img: Display image
--
-- <img=texture:image/>
-- <img=texture:image,size/>
-- <img=texture:image,width,height/>
function RichText.set_text(self, text)
	self:clear()

	local words, settings, line_metrics = rich_text.create(text, self._settings, self.style)
	line_metrics = rich_text.adjust_to_area(words, settings, line_metrics, self.style)

	self._words = words
	self._line_metrics = line_metrics

	return words, line_metrics
end


function RichText:on_remove()
	self:clear()
end


--- Clear all created words.
function RichText:clear()
	if self._words then
		rich_text.remove(self._words)
		self._words = nil
	end
end


--- Get all words, which has a passed tag.
-- @tparam string tag
-- @treturn druid.rich_text.word[] words
function RichText:tagged(tag)
	if not self._words then
		return
	end

	return rich_text.tagged(self._words, tag)
end


--- Get all current words.
-- @treturn table druid.rich_text.word[]
function RichText:get_words()
	return self._words
end


--- Get current line metrics
--- @treturn druid.rich_text.lines_metrics
function RichText:get_line_metric()
	return self._line_metrics
end


function RichText:_create_settings()
	local root_size = gui.get_size(self.root)
	return {
		-- General settings
		-- Adjust scale using to fit the text to the root node area
		adjust_scale = 1,
		parent = self.root,
		width = root_size.x,
		height = root_size.y,
		combine_words = false, -- disabled now
		text_prefab = self.text_prefab,
		node_prefab = self.icon_prefab,

		-- Text Settings
		shadow = gui.get_shadow(self.text_prefab),
		outline = gui.get_outline(self.text_prefab),
		text_scale = gui.get_scale(self.text_prefab),
		text_leading = gui.get_leading(self.text_prefab),
		is_multiline = gui.get_line_break(self.text_prefab),

		-- Image settings
		image_pixel_grid_snap = false, -- disabled now
		node_scale = gui.get_scale(self.icon_prefab),
		image_scale = gui.get_scale(self.icon_prefab),
		default_animation = gui.get_flipbook(self.icon_prefab),
	}
end


return RichText
