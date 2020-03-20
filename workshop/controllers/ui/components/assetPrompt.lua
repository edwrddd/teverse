local controller = {}

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end
local shared = require("tevgit:workshop/controllers/shared.lua")
local ui = require("tevgit:workshop/controllers/ui/core/ui.lua")

local function prompt(assetType, callbackFunc)
    if (controller.window) then
        warn("Prompt already opened.")
    else
        if (engine:isAuthenticated()) then
            local user = engine:isAuthenticated()
            controller.window = ui.window(shared.workshop.interface, "Asset Picker",
                guiCoord(0, 450, 0, 430),
                guiCoord(0.5, -310, 0.5, -250),
                true,
                true
            )

            local infoText = ui.create("guiTextBox", controller.window.content, {
                size = guiCoord(.5, 0, .04, 0),
                position = guiCoord(0, 5, 0, 3),
                fontSize = 15
            }, "backgroundText")
            infoText.backgroundAlpha = 0
            infoText:setText("Showing all " ..assetType.. " for " ..tostring(user[3].username).. ".")

            local searchInput = ui.create("guiTextBox", controller.window.content, {
                size = guiCoord(.3, 0, .04, 0),
                position = guiCoord(0, 307, 0, 3),
                fontSize = 12,
                readOnly = false,
                align = 4,
                text = "Search",
                borderRadius = 3,
                wrap = true,
                multiline = false
            }, "backgroundText")
            searchInput.backgroundAlpha = 1
            searchInput:keyFocused(function(key)
                searchInput:setText("")
            end)

            local searchIcon = ui.create("guiImage", controller.window.content, {
                size = guiCoord(0, 10, 0, 10),
                position = guiCoord(0, 310, 0, 6),
                texture = "fa:s-search",
                borderRadius = 3,
                imageColour = colour(0, 0, 0),
                zIndex = 3
            })
            searchInput.backgroundAlpha = 1

            local scrollingFrame = ui.create("guiScrollView", controller.window.content, {
                name = "scroller",
                size = guiCoord(1, 0, 0.93, 0),
                position = guiCoord(0, 0, 0.07, 0)
            })
            scrollingFrame.backgroundAlpha = 0

            local errorText = ui.create("guiTextBox", scrollingFrame.content, {
                position = guiCoord(3, 0, 0, 0),
                size = guiCoord(1, 0, .05, 0), 
                fontSize = 14,
                multiline = true,
                wrap = true
            }, "error")
            
            if (string.lower(assetType) == "images") or (string.lower(assetType) == "audio") or (string.lower(assetType) == "meshes") or (string.lower(assetType) == "games") then
                local http = shared.workshop:getHttp()
                local getAsset = http.get(nil, tostring("https://teverse.com/api/users/e6238438-0642-4a7d-b769-d7d0f3d601aa/" ..string.lower(assetType))) --..tostring(user[3].id).. "/" ..string.lower(assetType)))
                if getAsset then
                    local response = engine.json.decode(nil, http.urlDecode(nil, getAsset.body))

                    if string.lower(assetType) == "images" then
                        local x = 0.07
                        local y = 0
                        for i,v in pairs(response) do
                            local frame = ui.create("guiFrame", scrollingFrame, {
                                position = guiCoord(x, 0, y, 0),
                                size = guiCoord(0.25, 0, .2, 0),
                                cropChildren = true,
                                name = v.name
                            })
                            frame.backgroundAlpha = 0
                            x = x + 0.30
                            if x >= 0.9 then y = y + 0.23 end
                            if x >= 0.9 then x = 0.07 end

                            local thmbPreview = ui.create("guiImage", frame, {
                                position = guiCoord(0, 2, 0, -7),
                                size = guiCoord(0, 100, 0, 100),
                                texture = v.locator
                            })
                            thmbPreview.backgroundAlpha = 0

                            local hoverName = ui.create("guiTextBox", frame, {
                                position = guiCoord(0, 0, 1.25, 0),
                                size = guiCoord(1, 0, 0.15, 0),
                                align = 4,
                                backgroundAlpha = 0.8,
                                backgroundColour = colour(0,0,0),
                                zIndex = 2,
                                fontSize = 10
                            })
                            hoverName:setText(tostring(v.name))

                            thmbPreview:mouseFocused(function()
                                local tween;
                                tween = engine.tween:begin(hoverName, 0.15, {
                                    position = guiCoord(0, 0, 0.85, 0)
                                }, "inOutQuad", function()
                                    --idk
                                end)
                            end)
                            thmbPreview:mouseUnfocused(function()
                                local tween;
                                tween = engine.tween:begin(hoverName, 0.15, {
                                    position = guiCoord(0, 0, 1.25, 0)
                                }, "inOutQuad", function()
                                    --idk
                                end)
                            end)
                            thmbPreview:mouseLeftPressed(function()
                                controller.window:destroy()
                                controller.window = nil
                                return callbackFunc(v)
                            end)
                        end
                        scrollingFrame.canvasSize = guiCoord(1, 0, y, 0)
                    elseif string.lower(assetType) == "audio" then
                        local x = 0.07
                        local y = 0
                        for i,v in pairs(response) do
                            local frame = ui.create("guiFrame", scrollingFrame, {
                                position = guiCoord(x, 0, y, 0),
                                size = guiCoord(0.25, 0, .2, 0),
                                cropChildren = true,
                                name = v.name
                            })
                            frame.backgroundAlpha = 0
                            x = x + 0.30
                            if x >= 0.9 then y = y + 0.23 end
                            if x >= 0.9 then x = 0.07 end

                            local thmbPreview = ui.create("guiImage", frame, {
                                position = guiCoord(0, 2, 0, -7),
                                size = guiCoord(0, 100, 0, 100),
                                texture = v.locator
                            })
                            thmbPreview.backgroundAlpha = 0

                            local hoverName = ui.create("guiTextBox", frame, {
                                position = guiCoord(0, 0, 1.25, 0),
                                size = guiCoord(1, 0, 0.15, 0),
                                align = 4,
                                backgroundAlpha = 0.8,
                                backgroundColour = colour(0,0,0),
                                zIndex = 2,
                                fontSize = 10
                            })
                            hoverName:setText(tostring(v.name))

                            thmbPreview:mouseFocused(function()
                                local tween;
                                tween = engine.tween:begin(hoverName, 0.15, {
                                    position = guiCoord(0, 0, 0.85, 0)
                                }, "inOutQuad", function()
                                    --idk
                                end)
                            end)
                            thmbPreview:mouseUnfocused(function()
                                local tween;
                                tween = engine.tween:begin(hoverName, 0.15, {
                                    position = guiCoord(0, 0, 1.25, 0)
                                }, "inOutQuad", function()
                                    --idk
                                end)
                            end)
                            thmbPreview:mouseLeftPressed(function()
                                controller.window:destroy()
                                controller.window = nil
                                return callbackFunc(v)
                            end)
                        end
                        scrollingFrame.canvasSize = guiCoord(1, 0, y, 0)
                    elseif string.lower(assetType) == "meshes" then
                        local x = 0.07
                        local y = 0
                        for i,v in pairs(response) do
                            local frame = ui.create("guiFrame", scrollingFrame, {
                                position = guiCoord(x, 0, y, 0),
                                size = guiCoord(0.25, 0, .2, 0),
                                cropChildren = true,
                                name = v.name
                            })
                            frame.backgroundAlpha = 0
                            x = x + 0.30
                            if x >= 0.9 then y = y + 0.23 end
                            if x >= 0.9 then x = 0.07 end

                            local thmbPreview = ui.create("guiImage", frame, {
                                position = guiCoord(0, 2, 0, -7),
                                size = guiCoord(0, 100, 0, 100),
                                texture = v.locator
                            })
                            thmbPreview.backgroundAlpha = 0

                            local hoverName = ui.create("guiTextBox", frame, {
                                position = guiCoord(0, 0, 1.25, 0),
                                size = guiCoord(1, 0, 0.15, 0),
                                align = 4,
                                backgroundAlpha = 0.8,
                                backgroundColour = colour(0,0,0),
                                zIndex = 2,
                                fontSize = 10
                            })
                            hoverName:setText(tostring(v.name))

                            thmbPreview:mouseFocused(function()
                                local tween;
                                tween = engine.tween:begin(hoverName, 0.15, {
                                    position = guiCoord(0, 0, 0.85, 0)
                                }, "inOutQuad", function()
                                    --idk
                                end)
                            end)
                            thmbPreview:mouseUnfocused(function()
                                local tween;
                                tween = engine.tween:begin(hoverName, 0.15, {
                                    position = guiCoord(0, 0, 1.25, 0)
                                }, "inOutQuad", function()
                                    --idk
                                end)
                            end)
                            thmbPreview:mouseLeftPressed(function()
                                controller.window:destroy()
                                controller.window = nil
                                return callbackFunc(v)
                            end)
                        end
                        scrollingFrame.canvasSize = guiCoord(1, 0, y, 0)
                    elseif string.lower(assetType) == "games" then
                        local x = 0.07
                        local y = 0
                        for i,v in pairs(response) do
                            local frame = ui.create("guiFrame", scrollingFrame, {
                                position = guiCoord(x, 0, y, 0),
                                size = guiCoord(0.25, 0, .2, 0),
                                cropChildren = true,
                                name = v.name
                            })
                            frame.backgroundAlpha = 0
                            x = x + 0.30
                            if x >= 0.9 then y = y + 0.23 end
                            if x >= 0.9 then x = 0.07 end

                            local thmbPreview = ui.create("guiImage", frame, {
                                position = guiCoord(0, 2, 0, -7),
                                size = guiCoord(0, 100, 0, 100),
                                texture = "tevurl:" ..v.thumbnail
                            })
                            thmbPreview.backgroundAlpha = 0

                            local hoverName = ui.create("guiTextBox", frame, {
                                position = guiCoord(0, 0, 1.25, 0),
                                size = guiCoord(1, 0, 0.15, 0),
                                align = 4,
                                backgroundAlpha = 0.8,
                                backgroundColour = colour(0,0,0),
                                zIndex = 2,
                                fontSize = 10
                            })
                            hoverName:setText(tostring(v.name))

                            thmbPreview:mouseFocused(function()
                                local tween;
                                tween = engine.tween:begin(hoverName, 0.15, {
                                    position = guiCoord(0, 0, 0.85, 0)
                                }, "inOutQuad", function()
                                    --idk
                                end)
                            end)
                            thmbPreview:mouseUnfocused(function()
                                local tween;
                                tween = engine.tween:begin(hoverName, 0.15, {
                                    position = guiCoord(0, 0, 1.25, 0)
                                }, "inOutQuad", function()
                                    --idk
                                end)
                            end)
                            thmbPreview:mouseLeftPressed(function()
                                controller.window:destroy()
                                controller.window = nil
                                return callbackFunc(v)
                            end)
                        end
                        scrollingFrame.canvasSize = guiCoord(1, 0, y, 0)
                    end

                    searchInput:textInput(function(keywords)
                        local children = scrollingFrame:getDescendants()
                        local x1 = 0.07
                        local y1 = 0
                        for i,v in pairs(children) do
                            if v.className == "guiFrame" then
                                local frameChildren = v:getDescendants()
                                for x,y in pairs(frameChildren) do
                                    if y.className == "guiTextBox" then
                                        local lower = string.lower(y.text)
                                        if string.match(lower, string.lower(keywords)) then
                                            v.visible = true
                                            v.position = guiCoord(x1, 0, y1, 0)
                                            x1 = x1 + 0.30
                                            if x1 >= 0.9 then y1 = y1 + 0.23 end
                                            if x1 >= 0.9 then x1 = 0.07 end
                                        else
                                            v.visible = false
                                        end
                                    end
                                end
                            end
                        end
                    end)
                else
                    errorText:setText("An unexpected error occured while trying to fetch " ..assetType.. "s.\nError: Invalid response as nil or request error.")
                end
            else
                error("Unknown asset type. Options: images, audio, meshes, games")
            end

            controller.window.visible = true
        else
            warn("Unauthenticated clients cannot open assets.")
        end
    end
end
controller.prompt = prompt

return controller