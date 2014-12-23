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
	cloud = love.graphics.newImage("cloud_plain.png")
        present["image"] = love.graphics.newImage("present.png")
        present["limbs"] = love.graphics.newImage("limbs.png")

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
  if game_state == 0 then
    title_update(dt)
  elseif game_state == 1 then
    present_shooter_update(dt)
  elseif game_state == 2 then
  elseif game_state == 3 then
  end
end

function love.draw()
  if game_state == 0 then
    title_draw()
  elseif game_state == 1 then
    present_shooter_draw()
  elseif game_state == 2 then
  elseif game_state == 3 then
  end
end

thief = {
  speed = 0,
  x = -100
}

function title_update(dt)
end

function title_draw()
end

function present_shooter_update(dt)
        --get the size of our window
	width = love.graphics.getWidth()
	height = love.graphics.getHeight()
	
        --get the top coordinate for the grinch
        grinch["top"] = height - grinch.height


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
            present.x = 900
          end
        end
        --update the grinch
        grinch:update(dt)
        --arc the presents
        present:update(dt)
end

function present_shooter_draw()
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

function love.keypressed(k)
  if k == " " then
    try_shot()
  end
end

grinch = {
  speed  = 200,
  width  = 180,
  height = 204,
  left_offset = 18,
  right_offset = 112,
  position = 18,
  recoil = 0,
  recoil_speed = 7,
  recoil_size = 7,
  gun_top = 0
}

function grinch:update(dt)
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
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(self.image, self.position, self.top)
  love.graphics.draw(self.gun, self.position, self.top+self.gun_top)
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
  love.graphics.rectangle("line",self.x+self.hit_x,self.y+self.hit_y,self.hit_w,self.hit_h)
end

--shots will have x,y,speed
shots = {}
shot_xoffset = 84
shot_yoffset = 190
shot_speed = 300

function try_shot()
  if grinch.recoil == 0 then
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
