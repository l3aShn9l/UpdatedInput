local component = require("druid.component")

---@class component_name : druid.base_component
local Component = component.create("component_name")

local SCHEME = {
    ROOT = "root",
    BUTTON = "button",
}


-- Component constructor. Template name and nodes are optional. Pass it if you use it in your component
function Component:init(template, nodes)
    self:set_template(template)
    self:set_nodes(nodes)
    self.root = self:get_node(SCHEME.ROOT)
    self.druid = self:get_druid()

    self.button = self.druid:new_button(SCHEME.BUTTON, function() end)
end


-- [OPTIONAL] Call on component remove or on druid:final
function Component:on_remove()
end


return Component
