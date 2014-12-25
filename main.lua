-------------------------------------------------
-- LOVE: Passing Clouds Demo								
-- Website: http://love.sourceforge.net			
-- Licence: ZLIB/libpng									
-- Copyright (c) 2006-2009 LOVE Development Team
-------------------------------------------------

function love.load()
        --setup the random seed
        math.randomseed(os.time())

	-- The various images used.
	grinch["image"] = love.graphics.newImage("grinch_no_gun.png")
        grinch["gun"] = love.graphics.newImage("grinch_gun.png")
        thief["image"] = love.graphics.newImage("grinch_push.png")
	cloud = love.graphics.newImage("cloud_plain.png")
        present["image"] = love.graphics.newImage("present.png")
        present["limbs"] = love.graphics.newImage("limbs.png")
        family = love.graphics.newImage("family.png")
        pile = love.graphics.newImage("present_pile.png")
        jon["head"] = love.graphics.newImage("jon_head.png")
        jon["jaw"] = love.graphics.newImage("jon_jaw.png")
        jon["render"]=boss_render
        jon["move"] = boss_move
        jon["jaw_update"]=boss_jaw_update
        katie["head"] = love.graphics.newImage("katie_head.png")
        katie["jaw"] = love.graphics.newImage("katie_jaw.png")
        katie["render"]=boss_render
        katie["move"] = boss_move
        katie["jaw_update"]=boss_jaw_update
        sad_kids = love.graphics.newImage("sad_kids.jpg")
        sad_aidan = love.graphics.newImage("sad_aidan.jpg")
        sad_val = love.graphics.newImage("sad_val.jpg")
        sad_mouth = love.graphics.newImage("sad_mouth.png")
        cool_baby = love.graphics.newImage("cool_baby.jpg")
        hate = love.graphics.newImage("h8.png")
        xmas = love.graphics.newImage("xmas.png")

        --for i,v in ipairs(tear_sources) do
        --  v["draw"] = tear_draw
        --end
	-- Set the background color to green.
	love.graphics.setBackgroundColor(0xa1, 0xff, 0xa1)
	
	-- Spawn some clouds.
	for i=1,3 do
		spawn_cloud(math.random(-100, 900), math.random(-100, 700), 80 + math.random(0, 50))
	end
	
end

--0 is title page
--1 is present shooter
--2 is boss level
--3 is ending
game_state = 0

function love.update(dt)
  --get the size of our window
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()
  
  if game_state < 1 then
    title_update(dt)
  elseif game_state == 1 then
    present_shooter_update(dt)
  elseif game_state < 2 then
    present_transition_update(dt)
  elseif game_state == 2 then
    boss_shooter_update(dt)
  elseif game_state == 3 then
    ending_update(dt)
  end
end

function love.draw()
  if game_state < 1 then
    title_draw()
  elseif game_state == 1 then
    present_shooter_draw()
  elseif game_state < 2 then
    present_transition_draw()
  elseif game_state == 2 then
    boss_shooter_draw()
  elseif game_state == 3 then
    ending_draw()
  end
end

function render_controls()
  love.graphics.setColor(0,255,0,150)
  love.graphics.rectangle("fill",0, height-150,250,150)
  love.graphics.rectangle("fill",width-250, height-150,250,150)
  love.graphics.setColor(255,0,0,150)
  love.graphics.triangle("fill",100,height,50,height-25,100,height-50)
  love.graphics.rectangle("fill",100,height-40,50,30)
  love.graphics.triangle("fill",width-100,height,width-50,height-25,width-100,height-50)
  love.graphics.rectangle("fill",width-150,height-40,50,30)
  love.graphics.print("left",100,height-30)
  love.graphics.print("right",width-130,height-30)
  love.graphics.print("space",350,height-30)
end

thief = {
  speed = 100,
  x = -300,
  --x = -233,
  offset = 0
}

present_scale = 0
pulse_timer = 0

function title_update(dt)
  if pulse_timer == 0 and game_state > 0 then
    thief.x = thief.x + thief.speed*dt
    if thief.x > width then
      game_state = 1
    elseif thief.x > -233 then
      thief.offset = thief.x + 233
    end
  else
    pulse_timer = pulse_timer + 2*dt
    if pulse_timer > math.pi then
      pulse_timer = 0
    end
    present_scale = 1 + math.sin(pulse_timer)/100
  end
end

function title_draw()
  love.graphics.draw(family,0,0)
  love.graphics.draw(pile,400+thief.offset,350,0,5/4*present_scale,2/3*present_scale,300,0)
  if game_state > 0 then
    love.graphics.draw(thief.image,thief.x,height - 190)
  end
end

presents_killed = 0

function present_shooter_update(dt)
  -- Update clouds, iterating backwards for safe removal of off-screen ones.
  try_spawn_cloud(dt)
  for k=#clouds,1,-1 do
    local c = clouds[k]
    c.x = c.x + c.s * dt
    if c.x > width then
      table.remove(clouds, k)
    end
  end

  --update the shots
  for i, v in ipairs(shots) do
    --love.graphics.print(v.render,100,250)
    v:update(dt)
    if v.y < 0 then
      table.remove(shots,i)
    end
    if CheckCollision(present.x+present.hit_x,present.y+present.hit_y,present.hit_w,present.hit_h,v.x,v.y,5,10) then
      table.remove(shots,i)
      present.x = width+1
      presents_killed = presents_killed + 1
      game_state = 1.5
      transition_time = 3
    end
  end

  --update the grinch
  grinch:update(dt)
  --arc the presents
  present:update(dt)
end

function present_shooter_draw()
        render_controls()
        --draw the clouds first, they are in the background
	love.graphics.setColor(255, 255, 255, 200)
	for k, c in ipairs(clouds) do
		love.graphics.draw(cloud, c.x, c.y)
	end
        --next draw the shot, it goes behind the gun
        for i, v in ipairs(shots) do
          v:render()
        end
        --love.graphics.print(test,100,250)
	
        grinch:render()
        present:render()
end

transition_time = 5

function present_transition_update(dt)
  transition_time = transition_time - dt
  if presents_killed == 4 then
    if transition_time < 0 then game_state = 2 end
    jon:jaw_update(dt)
    katie:jaw_update(dt)
  elseif transition_time < 0 then
    game_state = 1
  end
end

function present_transition_draw()
  love.graphics.setColor(255, 255, 255, 255)
  if presents_killed == 1 then
    love.graphics.draw(cool_baby,0,-200)
    love.graphics.setColor(0, 255, 0, 100)
    love.graphics.draw(hate,5,5)
    love.graphics.setColor(255, 255, 255, 150)
    love.graphics.draw(hate,0,0)
  elseif presents_killed == 2 then
    love.graphics.draw(sad_val,0,0)
    love.graphics.draw(sad_mouth,425,265,0,2/3,1/2)
  elseif presents_killed == 3 then
    love.graphics.draw(sad_aidan,0,0)
  elseif presents_killed == 4 then
    jon:render()
    katie:render()
    love.graphics.print("Hey, you shot our presents and made our kids sad!",300,300)
    love.graphics.print("We are gonna get you. With lasers!",350,350)
  end
end

jon = {
  speed_min = -175,
  speed_max = 175,
  speed_time = 0,
  v_speed = 0,
  h_speed = 0,
  jaw_max = 30,
  jaw_min = 0,
  jaw_offset = 0,
  jaw_t = 0,
  jaw_speed = 4,
  x_offset = -30,
  y_offset = 0,
  x = 400,
  y = 0,
  scale = 1/5,
  mouth_x = 20,
  mouth_y = 70,
  mouth_width =  80,
  mouth_height = 70,
  hit_x = 0,
  hit_y = 0,
  hit_w = 130,
  hit_h = 160,
  health = 6,
  red_time = 0,
  lasers = {{x=33,y=40},{x=95,y=43}},
  laser_time = 2,
}

katie = {
  speed_min = -175,
  speed_max = 175,
  speed_time = 0,
  v_speed = 0,
  h_speed = 0,
  jaw_max = 25,
  jaw_min = 0,
  jaw_offset = 0,
  jaw_t = 0,
  jaw_speed = 2,
  x_offset = -40,
  y_offset = -20,
  x = 0,
  y = 0,
  scale = 5/12,
  mouth_x = 50,
  mouth_y = 130,
  mouth_width =  70,
  mouth_height = 50,
  hit_x = 25,
  hit_y = 0,
  hit_w = 115,
  hit_h = 190,
  health = 6,
  red_time = 0,
  lasers = {{x=55,y=90},{x=115,y=90}},
  laser_time = 2,
}

function boss_render(self)
  love.graphics.setColor(255, 0, 0, 100)
  if self.red_time <= 0 then
    love.graphics.rectangle("fill",self.x+self.mouth_x,self.y+self.mouth_y,self.mouth_width,self.mouth_height)
    love.graphics.setColor(255, 255, 255, 255)
  end
  love.graphics.draw(self.head,self.x+self.x_offset,self.y+self.y_offset,0,self.scale,self.scale)
  love.graphics.draw(self.jaw,self.x+self.x_offset,self.y+self.y_offset+self.jaw_offset,0,self.scale,self.scale)
  if self.laser_time < 1/2 then
  love.graphics.setColor(255, 0, 0, 50)
    for i,v in ipairs(self.lasers) do
      love.graphics.circle("fill",self.x+v.x,self.y+v.y,10,10)
    end
  end
 if self.laser_time < 0 then
     for i,v in ipairs(self.lasers) do
      love.graphics.line(self.x+v.x,self.y+v.y,self.x+v.x,height)
    end
  end
  --hitbox
  --love.graphics.setColor(255, 255, 0, 255)
  --love.graphics.rectangle("line",self.x+self.hit_x,self.y+self.hit_y,self.hit_w,self.hit_h)
end

function boss_move(self, dt)
  self.laser_time = self.laser_time - dt
  self.speed_time = self.speed_time - dt
  if self.speed_time <=0 then
    self.speed_time = math.random()
    self.h_speed = math.random(self.speed_min,self.speed_max)
    self.v_speed = math.random(self.speed_min,self.speed_max)
  end
  if self.laser_time < -1 then
    self.laser_time = math.random(1,5)
  end
  self.x = self.x+self.h_speed*dt
  self.y = self.y+self.v_speed*dt
  if self.x < -self.hit_x then
    self.x = -self.hit_x
  elseif self.x > width-self.hit_w-self.hit_x then
    self.x = width - self.hit_w-self.hit_x
  end
  if self.y < -self.hit_y then
    self.y = -self.hit_y
  elseif self.y > height-self.hit_h-self.hit_y then
    self.y = height - self.hit_h-self.hit_y
  end
end

function boss_jaw_update(self, dt)
  self.jaw_t = self.jaw_t+self.jaw_speed*dt
  if self.jaw_t > math.pi then
    self.jaw_t = 0
  end
  self.jaw_offset = (self.jaw_max - self.jaw_min)*math.sin(self.jaw_t)+self.jaw_min
end

function boss_shooter_update(dt)
  -- Update clouds, iterating backwards for safe removal of off-screen ones.
  try_spawn_cloud(dt)
  for k=#clouds,1,-1 do
    local c = clouds[k]
    c.x = c.x + c.s * dt
    if c.x > width then
      table.remove(clouds, k)
    end
  end

  --update the shots
  for i, v in ipairs(shots) do
    --love.graphics.print(v.render,100,250)
    v:update(dt)
    if v.y < 0 then
      table.remove(shots,i)
    end
    if CheckCollision(katie.x+katie.hit_x,katie.y+katie.hit_y,katie.hit_w,katie.hit_h,v.x,v.y,5,10) then
      table.remove(shots,i)
      katie.health =  katie.health - 1
      katie.red_time = .25
    end
    if CheckCollision(jon.x+jon.hit_x,jon.y+jon.hit_y,jon.hit_w,jon.hit_h,v.x,v.y,5,10) then
      table.remove(shots,i)
      jon.health =  jon.health - 1
      jon.red_time = .25
    end
  end

  if jon.health > 0 then
    if jon.laser_time < 0 then
      for i,v in ipairs(jon.lasers) do
        if jon.x+v.x < grinch.position+grinch.hit_x+grinch.hit_w and jon.x+v.x > grinch.position+grinch.hit_x then
          grinch.red_time = 1
        end
      end
    end
    if CheckCollision(jon.x+jon.hit_x,jon.y+jon.hit_y,jon.hit_w,jon.hit_h,grinch.position+grinch.hit_x,grinch.top+grinch.hit_y,grinch.hit_w,grinch.hit_h) then
      grinch.red_time = 1
    end
  end
  if katie.health > 0 then
    if katie.laser_time < 0 then
      for i,v in ipairs(katie.lasers) do
        if katie.x+v.x < grinch.position+grinch.hit_x+grinch.hit_w and katie.x+v.x > grinch.position+grinch.hit_x then
          grinch.red_time = 1
        end
      end
    end
    if CheckCollision(katie.x+katie.hit_x,katie.y+katie.hit_y,katie.hit_w,katie.hit_h,grinch.position+grinch.hit_x,grinch.top+grinch.hit_y,grinch.hit_w,grinch.hit_h) then
      grinch.red_time = 1
    end
  end
  if jon.red_time > 0 then
    jon.red_time = jon.red_time - dt
  end
  if katie.red_time > 0 then
    katie.red_time = katie.red_time - dt
  end
  jon:jaw_update(dt)
  katie:jaw_update(dt)
  jon:move(dt)
  katie:move(dt)
  grinch:update(dt)

  if jon.health <=0 and katie.health <= 0 and jon.red_time <= 0 and katie.red_time <=0 then
    game_state = 3
  end
end

function boss_shooter_draw()
  render_controls()
  love.graphics.print("Hey, you shot our presents and made our kids sad!",300,300)
  love.graphics.print("We are gonna get you. With lasers!",350,350)
  --draw the clouds first, they are in the background
  love.graphics.setColor(255, 255, 255, 200)
  for k, c in ipairs(clouds) do
          love.graphics.draw(cloud, c.x, c.y)
  end
  --next draw the shot, it goes behind the gun
  for i, v in ipairs(shots) do
    v:render()
  end

  if jon.health > 0 then
    jon:render()
  end
  if katie.health > 0 then
    katie:render()
  end

  grinch:render()
end

tear_sources = {{x=305,y=195},{x=350,y=195},{x=530,y=375},{x=590,y=385},}
tear_time =  0
tear_speed = 100
tears = {}
function tear_draw(self)
  love.graphics.setColor(0, 0, 255, 50)
  -- giving the coordinates directly
  love.graphics.polygon('fill', self.x+10, self.y+10, self.x+20, self.y+10, self.x+15, self.y+0)
end

end_time = 10

function ending_update(dt)
  if end_time > 0 then
    end_time = end_time - dt
    tear_time = tear_time - dt
    if tear_time < 0 then
      for i,v in ipairs(tear_sources) do
        table.insert(tears, { x = v.x, y = v.y, render = tear_draw} )
      end
      tear_time = .35
    end
    for i,v in ipairs(tears) do
      v.y = v.y+tear_speed*dt
      if v.y+height then
        table.remove(shots,i)
      else
      end
    end
  else
  end
end

function ending_draw()
  if end_time > 0 then
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(sad_kids,0,0)
    for i,v in ipairs(tears) do
      v:render()
    end
    love.graphics.setColor(255, 255, 255, 155)
    love.graphics.triangle("fill",440,40,700,40,440,300)
    if end_time < 9 then
      love.graphics.print("You destroyed their gifts.",450,50)
      if end_time < 8 then
        love.graphics.print("You orphaned them.",450,80)
        if end_time < 7 then
          love.graphics.print("Merry Christmas.",450,110)
          if end_time < 6 then
            love.graphics.print("You animal.",450,140)
            if end_time < 4 then
              love.graphics.print("jk",450,170)
              if end_time < 3.4 then
                love.graphics.print("jk",450,200)
              end
            end
          end
        end
      end
    end
  else
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(xmas,0,0)
  end
end

function love.mousepressed( x, y, button )
  if game_state == 0 then
    game_state = 0.5
  elseif game_state == 1 or game_state == 2 then
    if CheckCollision(x,y,0,0,0,height-150,250,150) then
      grinch.position = grinch.position-20
    elseif CheckCollision(x,y,0,0,width-250,height-150,250,150) then
      grinch.position = grinch.position+20
    else
      try_shot()
    end
  --elseif game_state == 1.5 then
  --  game_state = presents_killed == 4 and 2 or 1
  elseif game_state == 3 then
    if end_time <= 0 then
      thief.x = -300
      thief.offset = 0
      game_state = 0
      presents_killed = 0
      jon.health = 6
      katie.health = 6
    end
  end
end

function love.keypressed(k)
  if (game_state == 1 or game_state == 2) and k == " " then
    try_shot()
  end
  --[[
  if game_state == 1.5 then
    game_state = presents_killed == 4 and 2 or 1
  end
  --]]
end

grinch = {
  top = 0,
  speed  = 200,
  width  = 180,
  height = 204,
  left_offset = 18,
  right_offset = 112,
  position = 18,
  recoil = 0,
  recoil_speed = 7,
  recoil_size = 7,
  gun_top = 0,
  hit_x =  20,
  hit_y = 100,
  hit_w = 80,
  hit_h = 100,
  red_time = 0,
}

function grinch:update(dt)
  --get the top coordinate for the grinch
  self["top"] = height - grinch.height
  --move the grinch as necessary
  if love.keyboard.isDown('left') or love.keyboard.isDown('h') then
    grinch:left(dt)
  end
  if love.keyboard.isDown('right') or love.keyboard.isDown('l') then
    grinch:right(dt)
  end
  --if we shot, recoil the gun
  if self.recoil > 0 then
    self.recoil = self.recoil - self.recoil_speed*dt
    if self.recoil < 0 then
      self.recoil = 0
    end
    self.gun_top = self.recoil_size*math.sin(self.recoil)
  end
  if self.red_time > 0 then
    self.red_time = self.red_time - dt
  end
end

function grinch:left(dt)
  self.position = self.position - self.speed*dt
  if self.position < 0 - self.left_offset then
    self.position = 0 - self.left_offset
  end
end

function grinch:right(dt)
  self.position = self.position + self.speed*dt
  if self.position > width - self.right_offset then
    self.position = width - self.right_offset
  end
end

function grinch:render()
  if self.red_time > 0 then
    love.graphics.setColor(255, 0, 0, 100)
  else
    love.graphics.setColor(255, 255, 255, 255)
  end
  love.graphics.draw(self.image, self.position, self.top)
  love.graphics.draw(self.gun, self.position, self.top+self.gun_top)
  --hitbox
  --love.graphics.setColor(255, 255, 0, 255)
  --love.graphics.rectangle("line",self.position+self.hit_x,self.top+self.hit_y,self.hit_w,self.hit_h)
end

--the presents
present = {
  h_speed = 150,
  v_speed = 0,
  r_speed = 3,
  arm_direction = -(1/4),
  v_accel = -30,
  v_start = 0,
  v_vmax = 500,
  v_vmin = 0,
  --v_amax = -30,
  --v_amin = -30,
  y = 0,
  x = 900,
  rotation = 0,
  arm_rot = 0,
  t = 0,
  --hitbox
  hit_x = -95,
  hit_y = -40,
  hit_w = 87,
  hit_h = 75,
}

function present:update(dt)
  --pos=y=at^2+bt+c
  --vel=2at+b
  ---b/2a=t_max
  -- height = a(-b/2a)^2+b(-b/2a)+c
  -- height=b^2/4a-2b^2/4a+c
  -- height+b^2/4a=c
  --acc=2a
  --x=t*h_speed
  if self.x >= width then
    self.v_speed = math.random(self.v_vmin,self.v_vmax)
    --self.v_accel = math.random(self.v_amax,self.v_amin)
    self.v_start = height+self.v_speed^2/(4*self.v_accel)
    self.t = 0
    self.x = 0
    self.y = height - self.v_start
  else
    self.t = self.t + dt
    self.x = self.t * self.h_speed
    self.y = height - (self.v_accel*self.t^2+self.v_speed*self.t+self.v_start)
  end
  self.rotation =  self.rotation + self.r_speed*dt
  if self.arm_rot > 1/6 then
    self.arm_direction = -self.arm_direction
    self.arm_rot = 1/6
  elseif self.arm_rot < -1/4 then
    self.arm_direction = -self.arm_direction
    self.arm_rot = -1/4
  end
  self.arm_rot = self.arm_rot+self.r_speed*self.arm_direction*dt
  if self.rotation > 2*math.pi then
    self.rotation = self.rotation - 2*math.pi
  end
end

function present:render()
  love.graphics.setColor(255, 255, 0, 200)
  --love.graphics.draw(self.image, self.x-50, self.y,self.rotation,1,1,195,155)
  love.graphics.draw(self.limbs, self.x-50, self.y,self.rotation+self.arm_rot,1,1,-15,55)
  love.graphics.draw(self.limbs, self.x-50, self.y,self.rotation-self.arm_rot,-1,1,-20,55)
  love.graphics.draw(self.image, self.x-50, self.y,self.rotation,1,1,100,80)
  --hitbox
  --love.graphics.rectangle("line",self.x+self.hit_x,self.y+self.hit_y,self.hit_w,self.hit_h)
end

--shots will have x,y,speed
shots = {}
shot_xoffset = 84
shot_yoffset = 190
shot_speed = 300

function try_shot()
  if grinch.recoil == 0 and grinch.red_time <= 0 then
    grinch.recoil = math.pi
    table.insert(shots, { x = grinch.position+shot_xoffset, y = height-shot_yoffset, render=shot_render, update=shot_update} )
  end
end

function shot_update(self,dt)
  self.y = self.y - shot_speed*dt
end

function shot_render(self)
  love.graphics.setColor(150, 150, 150, 80)
  love.graphics.rectangle("fill",self.x-1,self.y-1,5+3,10+4)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.rectangle("fill",self.x,self.y,5,10)
  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.line(self.x,self.y,self.x+5,self.y+5)
  love.graphics.line(self.x,self.y+6,self.x+4,self.y+10)
end

-- Holds the passing clouds.
clouds = {}

cloud_buffer = 0
cloud_interval = 5

-- Inserts a new cloud.
function try_spawn_cloud(dt)

	cloud_buffer = cloud_buffer + dt
	
	if cloud_buffer > cloud_interval then
		cloud_buffer = 0
		spawn_cloud(-512, math.random(-50, 500), 80 + math.random(0, 50))
	end
end

function spawn_cloud(xpos, ypos, speed)
	table.insert(clouds, { x = xpos, y = ypos, s = speed } )
end

-- Collision detection function.
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
