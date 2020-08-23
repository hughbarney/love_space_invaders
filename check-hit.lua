
function check_hit()
   local y_bug
   local x_bug
   local row
   local col

   if not bullet_in_flight then return end

   -- bullet in same y range
   for col = 1,11 do
	  x_bug = x_pos + (col - 1)*x_alian_width
	  -- start with lowest bug first and work up
	  -- if a bug is missing skip it
	  for row = 5,1,-1 do
		 print("check_hit: alians[".. row .. "]["  .. col .. "]=" .. alians[row][col] ) 

		 local bug = alians[row][col]

		 -- if already killed then skip it
		 if not bug == " " then
			y_bug = y_pos + (row - 1)* y_alian_height

			print("check_hit: col:" .. col .. " row:" .. row .. " y_bug:" .. y_bug)
		 
			-- bullet in same x range
			if x_bullet > x_bug and x_bullet < x_bug + x_alian_width then
			   love.audio.play(boom_sound)
			   love.audio.rewind(boom_sound)
			   bullet_in_flight = false
			   -- mark as hit
			   alians[row][col] = " "
			   hit = not hit
			   return -- no point looking any further
			end
		 end --  else
	  end -- for
   end -- for
end
