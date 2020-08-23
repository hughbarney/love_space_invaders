--[[
Space Invaders in Love Lua
--]]

function init_globals()
   y_screenheight=love.graphics.getHeight()
   x_screenwidth=love.graphics.getWidth()

   t_alian = 0
   t_bullet = 0

   t_alian_max = 0.5
   t_bullet_max = 0.05

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

   xpos =  x_start
   ypos =  y_start

   y_debug = 550

   up = true
   direction = "up"
   count = 1

   key_press = ""
   space_key_down = false

   hit = false
   bullet_in_flight = false

   x_bullet = 0
   y_bullet = 0
   speed_bullet = 400  -- pixels per second

   row1 = { "T", "T", "T", "T", "T", "T", "T", "T", "T", "T", "T" }
   row2 = { "M", "M", "M", "M", "M", "M", "M", "M", "M", "M", "M" }
   row3 = { "M", "M", "M", "M", "M", "M", "M", "M", "M", "M", "M" }
   row4 = { "B", "B", "B", "B", "B", "B", "B", "B", "B", "B", "B" }
   row5 = { "B", "B", "B", "B", "B", "B", "B", "B", "B", "B", "B" }

   alians = { row1, row2, row3, row4, row5 }

end

function inc_x()
   -- calc next x, y
   xpos = xpos + x_inc
   if xpos > x_max then
	  xpos = x_start
	  inc_y()
   end
end

function inc_y()
   ypos = ypos + y_inc
   if ypos > y_max then
	  ypos = y_start
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

function check_hit()
   if bullet_in_flight then
	  -- bullet in same y range
	  if y_bullet > ypos and y_bullet < ypos + 64 then
		 -- bullet in same x range
		 if x_bullet > xpos and x_bullet < xpos + 64 then
			love.audio.play(boom_sound)
			love.audio.rewind(boom_sound)
			bullet_in_flight = false
			hit = not hit
		 end
	  end
   end
end

function alian_movement_calcs()
   -- do sounds
   if up then
	  love.audio.play(up_sound)
	  love.audio.rewind(up_sound)
   else
	  love.audio.play(dn_sound)
	  love.audio.rewind(dn_sound)
   end

   if up then 
	  direction = "up"
   else
	  direction = "down"
   end

   inc_x()
   up = not up
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

function paint_debug()
   local msg1 = "d_t=" .. d_t .. "  count = " .. count .. "  " .. direction .. " xpos=" .. xpos .. " ypos=" .. ypos .. " delta=" .. delta .. " key='" .. key_press .. "'"
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

   bug_up   = love.graphics.newImage("bug_up2.png")
   bug_down = love.graphics.newImage("bug_down2.png")

   bug_up_hit   = love.graphics.newImage("bug_up_hit2.png")
   bug_down_hit = love.graphics.newImage("bug_down_hit2.png")

   ship_img = love.graphics.newImage("ship.png")
   bullet_img = love.graphics.newImage("bullet.png")

   up_sound = love.audio.newSource("up.wav")
   dn_sound = love.audio.newSource("dn.wav")
   laser_sound = love.audio.newSource("laser.wav")
   boom_sound = love.audio.newSource("boom.wav")
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
   check_hit()
end

function love.draw()
   local row
   local line
   local invader

   for row = 1,5 do
	  for col = 1,11 do
		 invader = alians[row][col]

		 if up then
			if invader == "T" then
			   img = top_bug_up
			elseif invader == "M" then
			   img = mid_bug_up
			elseif invader == "B" then
			   img = bug_up
			end
		 else
			if invader == "T" then
			   img = top_bug_down
			elseif invader == "M" then
			   img = mid_bug_down
			elseif invader == "B" then
			   img = bug_down
			end
		 end

		 local x = xpos + col * 64
		 local y = ypos + row * 64

		 love.graphics.draw(img, x , y)
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

      if bullet_in_flight == false then
	     love.audio.play(laser_sound)
	     love.audio.rewind(laser_sound)
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
