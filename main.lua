--[[
Space Invaders in Love Lua
--]]

function init_globals()
   y_screenheight=love.graphics.getHeight()
   x_screenwidth=love.graphics.getWidth()

   x_alian_width = 40
   y_alian_height = 40

   t_alian = 0
   t_bullet = 0
   t_explode = 0

   t_alian_max = 0.5
   t_bullet_max = 0.05
   t_explode_max = 0.5

   x_start = 20
   y_start = 20
   x_max = x_screenwidth
   y_max = y_screenheight
   x_inc = 20
   y_inc = 20

   x_ship_max = x_max - 80
   ship_speed = 400
   x_ship = 0
   y_ship = 450

   delta_min = 10
   delta_delta = 5
   delta_max = 40
   delta = delta_max
   d_t = 0

   x_pos =  x_start
   y_pos =  y_start

   y_debug = 550

   up = true
   direction = "up"
   count = 1

   key_press = ""
   space_key_down = false

   hit = false
   hit_row = -1
   hit_col = -1
   bullet_in_flight = false
   alian_exploding = false

   x_bullet = 0
   y_bullet = 0
   speed_bullet = 500  -- pixels per second

   alians = { { "T", "T", "T", "T", "T", "T", "T", "T", "T", "T", "T" },
			  { "M", "M", "M", "M", "M", "M", "M", "M", "M", "M", "M" },
			  { "M", "M", "M", "M", "M", "M", "M", "M", "M", "M", "M" },
			  { "B", "B", "B", "B", "B", "B", "B", "B", "B", "B", "B" },
			  { "B", "B", "B", "B", "B", "B", "B", "B", "B", "B", "B" }
   }

end

function inc_x()
   -- calc next x, y
   x_pos = x_pos + x_inc
   if x_pos > x_max then
	  x_pos = x_start
	  inc_y()
   end
end

function inc_y()
   y_pos = y_pos + y_inc
   if y_pos > y_max then
	  y_pos = y_start
	  delta = delta_max
   else 
	  dec_delta()
   end
end

function dec_delta()
   delta = delta - delta_delta
   if delta < delta_min then
	  delta = delta_min
   end
end

function check_hit(dt)
   local y_bug
   local x_bug
   local row
   local col

   if not bullet_in_flight then return end

   col = 1 + ((x_bullet - x_pos) / x_alian_width)
   row = 1 + ((y_bullet - y_pos) / y_alian_height)

   col = math.floor(col)
   row = math.floor(row)

   --print(row .. "," .. col)

   -- validate are valid rows and columns
   if col < 1 or col > 11 then return end
   if row < 1 or row > 5 then return end

   if alians[row][col] == " " then return end
   if alians[row][col] == "H" then return end

   --print("hit " .. row .. "," .. col)
   love.audio.stop(boom_sound)
   love.audio.play(boom_sound)
   bullet_in_flight = false
   alian_exploding = true
   t_explode = 0
   -- mark as hit
   alians[row][col] = "H"

   -- record which was hit so we can timeout the explosion
   hit_row = row
   hit_col = col
end

function update_alian_explosion(dt)
   if alian_exploding == false then return end

   t_explode = t_explode + dt

   if t_explode >= t_explode_max then
	  t_explode = 0
	  alians[hit_row][hit_col] = " "
	  alian_exploding = false
   end
end

function update_bullet(dt)
   if bullet_in_flight == false then return end

   if y_bullet < 0 then
      bullet_in_flight = false
      y_bullet = y_ship
      return
   end

   y_bullet = y_bullet - dt*speed_bullet
end

function update_ship(dt)
	if love.keyboard.isDown("left") then
	   x_ship = x_ship - dt*ship_speed
	   if x_ship < 0 then
		  x_ship = 0
	   end
	end

	if love.keyboard.isDown("right") then
	   x_ship = x_ship + dt*ship_speed
	   if x_ship >= x_ship_max then
		  x_ship = x_ship_max
	   end
	end
end

function alian_movement_calcs()
   -- do sounds
   if up then
	  love.audio.stop(up_sound)
	  love.audio.play(up_sound)
   else
	  love.audio.stop(dn_sound)
	  love.audio.play(dn_sound)
   end

   if up then 
	  direction = "up"
   else
	  direction = "down"
   end

   inc_x()
   up = not up
end

function paint_debug()
   local msg1 = "d_t=" .. d_t .. "  count = " .. count .. "  " .. direction .. " x_pos=" .. x_pos .. " y_pos=" .. y_pos .. " delta=" .. delta .. " key='" .. key_press .. "'"
   local msg2 = "w=" .. x_screenwidth .. " h=" .. y_screenheight

   love.graphics.print(msg1, 1, y_debug)
   love.graphics.print(msg2, 1, y_debug + 10 )
end


-- ###########################################################################################
-- Callbacks
-- ###########################################################################################

function love.load()
   init_globals()

   top_bug_up = love.graphics.newImage("top_bug_up.png")
   top_bug_down = love.graphics.newImage("top_bug_down.png")

   mid_bug_up = love.graphics.newImage("mid_bug_up.png")
   mid_bug_down = love.graphics.newImage("mid_bug_down.png")

   bot_bug_up   = love.graphics.newImage("bot_bug_up.png")
   bot_bug_down = love.graphics.newImage("bot_bug_down.png")

   boom_img = love.graphics.newImage("boom.png")

   ship_img = love.graphics.newImage("ship.png")
   bullet_img = love.graphics.newImage("bullet.png")

   up_sound = love.audio.newSource("up.wav", "static")
   dn_sound = love.audio.newSource("dn.wav", "static")

   laser_sound = love.audio.newSource("laser.wav", "static")
   boom_sound = love.audio.newSource("boom.wav", "static")
end

function love.update(dt)
   t_alian = t_alian + dt

   -- is it time to update the alian matrix
   if t_alian >= t_alian_max then
	  t_alian = 0
	  alian_movement_calcs()
   end

   update_ship(dt)
   update_bullet(dt)
   check_hit(dt)
   update_alian_explosion(dt)
end

function love.draw()
   local row
   local line
   local invader
   local alian_dead

   for row = 1,5 do
	  for col = 1,11 do
		 invader = alians[row][col]
		 alian_dead = false

		 if up then
			if invader == "T" then
			   img = top_bug_up
			elseif invader == "M" then
			   img = mid_bug_up
			elseif invader == "B" then
			   img = bot_bug_up
			elseif invader == "H" then
			   img = boom_img
			else
			   alian_dead = true
			end
		 else
			if invader == "T" then
			   img = top_bug_down
			elseif invader == "M" then
			   img = mid_bug_down
			elseif invader == "B" then
			   img = bot_bug_down
			elseif invader == "H" then
			   img = boom_img
			else
			   alian_dead = true
			end
		 end

		 local x = x_pos + (col -1)* x_alian_width
		 local y = y_pos + (row -1)* y_alian_height

		 if not alian_dead then
			love.graphics.draw(img, x , y)
		 end
	  end
   end


   if bullet_in_flight == true then
      love.graphics.draw(bullet_img, x_bullet, y_bullet)  
   end

   love.graphics.draw(ship_img, x_ship, y_ship)
   paint_debug()
end

function love.keypressed(key, unicode)
   if key == ' ' then
      if bullet_in_flight == false and alian_exploding == false then
	     love.audio.stop(laser_sound)
	     love.audio.play(laser_sound)
	     space_key_down = true
		 bullet_in_flight = true
		 x_bullet = x_ship + 40
		 y_bullet = y_ship
      end
   elseif key == "q" then
	  os.exit()
   end
   key_press = key
end

function love.keyreleased(key, unicode)
   if key == ' ' then
	  space_key_down = false
   end
   key_press = key
end
