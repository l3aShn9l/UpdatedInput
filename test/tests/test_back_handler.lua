local mock_gui = require "deftest.mock.gui"
local mock_time = require("deftest.mock.time")
local mock_input = require("test.helper.mock_input")
local test_helper = require("test.helper.test_helper")
local druid_system = require("druid.druid")

return function()
	local druid = nil
	local context = test_helper.get_context()
	describe("Back Handler component", function()
		before(function()
			mock_gui.mock()
			mock_time.mock()
			mock_time.set(60)
			druid = druid_system.new(context)
		end)

		after(function()
			mock_gui.unmock()
			mock_time.unmock()
			druid:final(context)
			druid = nil
		end)

		it("Should react on back action id with custom args", function()
			local on_back_handler, on_back_handler_mock = test_helper.get_function()
			druid:new_back_handler(on_back_handler, { args = "custom" })

			druid:on_input(mock_input.key_pressed("key_back"))
			druid:on_input(mock_input.key_released("key_back"))
			assert(on_back_handler_mock.calls == 1)
			assert(on_back_handler_mock.params[1] == context)
			assert(on_back_handler_mock.params[2].args  == "custom")

			druid:on_input(mock_input.key_pressed("key_a"))
			druid:on_input(mock_input.key_released("key_a"))
			assert(on_back_handler_mock.calls == 1)
		end)
	end)
end
