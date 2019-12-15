-- Temporary file so I can draft my new level building utilities

local CN = require("crazy_numbers")
local util = require("util")

local lb = {}

-- Helpful numbers
local _left = -CN.COL_NUM/2
local _right = CN.COL_NUM/2
local _top = (display.contentHeight/CN.COL_WIDTH)/2
local _bottom = -(display.contentHeight/CN.COL_WIDTH)/2
local _halfSpikeWidth = CN.SPIKE_WIDTH/2
local _halfSpikeHeight = CN.SPIKE_HEIGHT/2

-- HELPER FUNCTIONS: Performs various operations to assist obstacle creation ==============================================================================

-- Wraps list of objects into a single stationary null centered at (0,0)
local function newCenteredNull(object_list)

-- Wrapper parent object, controls top to bottom screen movement
local function newParent(speed, name, topExtend, bottomExtend)

-- Duplicates object (with deep copy) and creates of list of length num_objects, leaving indicies specified in ignore as nil
local function newObjectList(num_objects, ignore, object)

-- Duplicates object for each vertex in nullModel's animation, leaving indicies specified in ignore empty
local function wrapLoopPath(nullModel, ignore, object)

-- BASIC OBJECTS: Returns stationary patterns of objects (Nestled in single stationary null) =======================================================================

-- On screen text
local function text(x, y, displayText, font, fontSize, color)

 -- Basic "atomic" objects, including coin, spike, black_square, black_circle, all powerups, and others
local function basicObject(x, y, rot, type)

-- Circle pattern of objects
-- local function objectCircle(centerPoint, radius, deg_offset, num_objects, ignore, object) -- Don't know if I need this if I make a circle animated thing

-- Rigid line of objects, where startPoint is the center and space_width is the distance between the center of each object
-- local function fillLine(centerPoint, space_width, num_objects, ignore, object) -- Also don't know if I need this if I you can make a still line from simpleLine

-- MODEL OBJECTS: Returns nulls with animated paths for use as models (single null object) =================================================================

-- Simple looping animated line (Objects jump from end back to beginning)
local function simpleLineModel(startPoint, endPoint, num_objects, period, ease)

-- Pingpong line (Objects reach end then play animation backwards to reach beginning)
local function pingpongLineModel(startPoint, endPoint, num_objects, period, ease)

-- 4 point square objects loop around
local function foursquareModel(centerPoint, edge_length, period, ease)

-- local function rotatingCircleModel(centerPoint, radius, deg_offset, num_objects, period, ease) <-- You can probably make this

-- ANIMATED OBJECTS: Returns animated patterns of objects (Nestled in single centered null) =========================================================================
local function simpleLine(startPoint, endPoint, num_objects, period, ignore, object)
local function pingpongLine(startPoint, endPoint, num_objects, period, ignore, object)
local function foursquare(centerPoint, edge_length, period, ignore, object)

-- FINISHED OBJECTS: Obstacles nestled within parent and ready for use in game (Nestled in parent null) ========================================================
local function lb.newSimpleLine_(speed, startPoint, endPoint, num_objects, period, ignore, object)
local function lb.newPingpongLine_(speed, startPoint, endPoint, num_objects, period, ignore, object)
local function lb.newFoursquare_(speed, centerPoint, edge_length, period, ignore, object)
local function lb.newCircle_(speed, centerPoint, radius, deg_offset, num_objects, ignore, object)
local function lb.newStillText_(speed, x, y, displayText, font, fontSize, color)
local function lb.fillAllColumns(speed, ignore_locations, object)

return lb