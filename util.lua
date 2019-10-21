-- Utilities! (yay?)

local CN = require("crazy_numbers")
local util = {}

-- Table clone method (Put this somewhere else when you are done plz)
-- Credit: http://lua-users.org/wiki/CopyTable
function util.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[util.deepcopy(orig_key)] = util.deepcopy(orig_value)
        end
        setmetatable(copy, util.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
-- Credit: https://gist.github.com/hashmal/874792
function util.tprint (tbl, indent)
if not indent then indent = 0 end
for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
if type(v) == "table" then
print(formatting)
util.tprint(v, indent+1)
else
print(formatting .. v)
end
end
end

-- Returns the default parent object that travels from the top of the
-- screen to the bottom in a given ammount of time (Stored in speed)
function util.newParentObstacle(speed)
    -- NOTE: You will probabily have to handle sizes of obstacles at some point
    local MIDDLE_Y = (display.contentHeight/CN.COL_WIDTH)/2
    local MIDDLE_X = (display.contentWidth/CN.COL_WIDTH)/2
    local parent = {
        name = "Parent",
        path = {MIDDLE_X, 2*MIDDLE_Y, MIDDLE_X, 0},
        time = {speed, speed},
        animation_options = {
          position_interpolation = nil,
          rotation = {0, 0},
          rotation_interpolation = nil,
        },
        on_complete = "destroy",
        object = nil,
        first_frame = 1,
        frame_counter = 2
    }
    return parent
end

-- Prints the name and nestled objects for an obstacle_data data structure
function util.printObstacleData(data, indent)
    if not data then return end
    if not indent then indent = 0 end
    local formatting = string.rep("\t", indent)    

    if type(data) == "table" then
        print(formatting..data.name..":")
    elseif type(data) == "string" then
        print(formatting..data)
    end

    util.printObstacleData(data.object, indent+1)
end


return util
