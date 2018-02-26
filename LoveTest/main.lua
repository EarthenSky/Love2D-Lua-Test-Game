-- wait ... is love2d's lua not a scripting language?

local util = require "util"

-- 6 tiles in a column, 6 columns in the main array
local tile_column = {true, true, true, true, true, true}
local tile_main = {
  util.deepCopy(tile_column), util.deepCopy(tile_column),
  util.deepCopy(tile_column), util.deepCopy(tile_column),
  util.deepCopy(tile_column), util.deepCopy(tile_column),
}

local red_pos = { x=1, y=6 }
local blue_pos = { x=6, y=1 }

local turn_number = 1

local is_wait_paused = false

function love.conf(t)
	t.console = true
end

function love.load()
  love.graphics.setNewFont(14)
  love.graphics.setColor(250, 250, 250)
  love.graphics.setBackgroundColor(100, 100, 100)

  -- set screen size
  if love.window.setMode(400, 500) == false then
    print("oh fuck...")
  end

  love.math.setRandomSeed(love.timer.getTime())
end

local TILE_SEPARAION_MOD = 50  -- in all caps cause a const var
local is_red_turn = true
local active_button = 0  -- 0 is none, 1 is button1, and 2 is button2

debug = "debug"
function love.draw()
  -- render tiles
  love.graphics.setNewFont(12)
  for i, p in ipairs(tile_main) do
    for j, p in ipairs(tile_main[i]) do
      if p == true then
        love.graphics.setColor(150, 150, 150)
        quad = love.graphics.newQuad(0, 0, TILE_SEPARAION_MOD, TILE_SEPARAION_MOD, 1, 1)
        love.graphics.draw(love.graphics.newImage("blank.png"), quad, j * TILE_SEPARAION_MOD, i * TILE_SEPARAION_MOD)

        love.graphics.setColor(250, 250, 250)
        love.graphics.print("tile", j * TILE_SEPARAION_MOD + 15, i * TILE_SEPARAION_MOD + 18)
      else
        love.graphics.setColor(250, 250, 250)
        love.graphics.print("void", j * TILE_SEPARAION_MOD + 12, i * TILE_SEPARAION_MOD + 18)
      end

    end
  end

  -- shows who's is the current turn
  love.graphics.setNewFont(24)
  if is_red_turn then
    love.graphics.setColor(250, 75, 75)
    quad = love.graphics.newQuad(0, 0, 200, 50, 1, 1)
    love.graphics.draw(love.graphics.newImage("blank.png"), quad, 100, 0)

    love.graphics.setColor(250, 250, 250)
    love.graphics.print("Red's turn", 140, 10)
  else
    love.graphics.setColor(75, 175, 250)
    quad = love.graphics.newQuad(0, 0, 200, 50, 1, 1)
    love.graphics.draw(love.graphics.newImage("blank.png"), quad, 100, 0)

    love.graphics.setColor(250, 250, 250)
    love.graphics.print("Blue's turn", 135, 10)
  end

  -- renders the two buttons
  love.graphics.setNewFont(20)
  if active_button == 0 then
    button1_render(false) button2_render(false)
  elseif active_button == 1 then
    button1_render(true) button2_render(false)
  elseif active_button == 2 then
    button1_render(false) button2_render(true)
  end

  --render players
  love.graphics.setColor(250, 75, 75)
  quad = love.graphics.newQuad(0, 0, 40, 40, 1, 1)
  love.graphics.draw(love.graphics.newImage("blank.png"), quad, red_pos.x * TILE_SEPARAION_MOD + 5, red_pos.y * TILE_SEPARAION_MOD + 5)

  love.graphics.setColor(75, 75, 250)
  quad = love.graphics.newQuad(0, 0, 40, 40, 1, 1)
  love.graphics.draw(love.graphics.newImage("blank.png"), quad, blue_pos.x * TILE_SEPARAION_MOD + 5, blue_pos.y * TILE_SEPARAION_MOD + 5)

  love.graphics.setColor(0, 0, 0)
  love.graphics.print("" .. turn_number, 10, 10)

end

function button1_render(is_active)
  if is_active then
    love.graphics.setColor(125, 200, 125)
  else
    love.graphics.setColor(110, 150, 110)
  end
  quad = love.graphics.newQuad(0, 0, 100, 100, 1, 1)
  love.graphics.draw(love.graphics.newImage("blank.png"), quad, 50, 350)

  love.graphics.setColor(250, 250, 250)
  love.graphics.print("Move", 73, 388)
end

function button2_render(is_active)
  if is_active then
    love.graphics.setColor(125, 200, 125)
  else
    love.graphics.setColor(110, 150, 110)
  end
  quad = love.graphics.newQuad(0, 0, 100, 100, 1, 1)
  love.graphics.draw(love.graphics.newImage("blank.png"), quad, 250, 350)

  love.graphics.setColor(250, 250, 250)
  love.graphics.print("Add Wall", 256, 388)
end

local is_stage_begining = false
local count = 0
function love.update(dt)
  if is_wait_paused == false then
    -- do action once when triggered
    if is_stage_begining then
      is_stage_begining = false

      is_wait_paused = true
      count = math.floor(turn_number / 10) + 1

    end
  else
    love.timer.sleep(0.25)

    flip_tile()
    count = count - 1

    if count <= 0 then
      is_red_turn = not is_red_turn
      is_wait_paused = false
      turn_number = turn_number + 1
    end

  end
end

-- choses a random tile and flips it.
function flip_tile(count)
  rand_x = love.math.random(1, 6)
  rand_y = love.math.random(1, 6)
  tile_main[rand_x][rand_y] = not tile_main[rand_x][rand_y]
end

function love.mousepressed(x, y, button, istouch)
  if is_wait_paused == false then
    if button == 1 then
      --[[ clamp mouse to avoid incorrect index to tile_main
      if util.checkBetween(math.floor(y/TILE_SEPARAION_MOD), 1, 6) == true and util.checkBetween(math.floor(x/TILE_SEPARAION_MOD), 1, 6) == true then
        xin = math.floor(y/TILE_SEPARAION_MOD)
        yin = math.floor(x/TILE_SEPARAION_MOD)
        tile_main[xin][yin] = not tile_main[xin][yin]
      end
      --]]

      if active_button == 1 then
        -- clamp mouse to avoid incorrect index value
        if util.checkBetween(math.floor(x/TILE_SEPARAION_MOD), 1, 6) == true and util.checkBetween(math.floor(y/TILE_SEPARAION_MOD), 1, 6) == true then
          xin = math.floor(x/TILE_SEPARAION_MOD)
          yin = math.floor(y/TILE_SEPARAION_MOD)
          if is_red_turn == true then
            if math.abs(red_pos.x - xin) + math.abs(red_pos.y - yin) == 1 then
              red_pos = {x=xin, y=yin}
              is_stage_begining = true
            end
          else
            if math.abs(blue_pos.x - xin) + math.abs(blue_pos.y - yin) == 1 then
              blue_pos = {x=xin, y=yin}
              is_stage_begining = true
            end
          end
        end

      elseif active_button == 2 and turn_stage == 0 then
        -- todo: this
      end

      active_button = check_buttons_clicked(x, y)
    end
  end
end

-- holds bounding bopx info for the buttons so that it can sense clicks
local button_bounds = {
  { left = 50, right = 150, top = 350, bottom = 450 },
  { left = 250, right = 350, top = 350, bottom = 450 }
}

function check_buttons_clicked(x, y)
  if x >= button_bounds[1].left and x <= button_bounds[1].right and y >= button_bounds[1].top and y <= button_bounds[1].bottom then
    return 1
  elseif x >= button_bounds[2].left and x <= button_bounds[2].right and y >= button_bounds[2].top and y <= button_bounds[2].bottom then
    return 2
  end

  return 0
end
