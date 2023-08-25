-- Manual Annotations --

---@class druid.rich_text.style
---@field COLORS table
---@field ADJUST_STEPS number
---@field ADJUST_SCALE_DELTA number

---@class druid.rich_text.metrics
---@field width number
---@field height number
---@field offset_x number|nil
---@field offset_y number|nil
---@field node_size vector3|nil @For images only

---@class druid.rich_text.lines_metrics
---@field text_width number
---@field text_height number
---@field lines table<number, druid.rich_text.metrics>

---@class druid.rich_text.word
---@field node Node
---@field relative_scale number
---@field color vector4
---@field position vector3
---@field offset vector3
---@field scale vector3
---@field size vector3
---@field metrics druid.rich_text.metrics
---@field pivot Pivot
---@field text string
---@field shadow vector4
---@field outline vector4
---@field font string
---@field image druid.rich_text.image
---@field default_animation string
---@field anchor number
---@field br boolean
---@field nobr boolean

---@class druid.rich_text.word.image
---@field texture string
---@field anim string
---@field width number
---@field height number

---@class druid.rich_text.settings
---@field parent Node
---@field size number
---@field fonts table<string, string>
---@field color vector4
---@field shadow vector4
---@field outline vector4
---@field position vector3
---@field image_pixel_grid_snap boolean
---@field combine_words boolean
---@field default_animation string
---@field node_prefab Node
---@field text_prefab Node

---@class GUITextMetrics
---@field width number
---@field height number
---@field max_ascent number
---@field max_descent number
