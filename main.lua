-------------------------------------------------
-- LOVE: Passing Clouds Demo								
-- Website: http://love.sourceforge.net			
-- Licence: ZLIB/libpng									
-- Copyright (c) 2006-2009 LOVE Development Team
-------------------------------------------------

grinch = {}
grinch["speed"] = 200
grinch["width"], grinch["height"] = 180,204
grinch["position"]=0

--grinch["image"]:getDimensions() doesn't work?

function love.load()
	
	-- The amazing music.
	--music = love.audio.newSource("prondisk.xm")
	
	-- The various images used.
	--[[
	body = love.graphics.newImage("body.png")
	ear = love.graphics.newImage("ear.png")
	face = love.graphics.newImage("face.png")
	logo = love.graphics.newImage("love.png")
	--]]
	gun = love.graphics.newImage("grinch_gun.png")

	grinch["image"] = love.graphics.newImage("grinch_no_gun.png")
        grinch["gun"] = love.graphics.newImage("grinch_gun.png")

	cloud = love.graphics.newImage("cloud_plain.png")

	-- Set the background color to green.
	love.graphics.setBackgroundColor(0xa1, 0xff, 0xa1)
	
	-- Spawn some clouds.
	for i=1,3 do
		spawn_cloud(math.random(-100, 900), math.random(-100, 700), 80 + math.random(0, 50))
	end
	
	love.graphics.setColor(255, 255, 255, 200)
	
	--love.audio.play(music, 0)
end

function love.update(dt)
--[[
	if love.joystick.isDown(1, 1) then
		nekochan:update(dt)
		nekochan:update(dt)
		nekochan:update(dt)
	end
	nekochan.x = nekochan.x + love.joystick.getAxis(1, 1)*200*dt
	nekochan.y = nekochan.y + love.joystick.getAxis(1, 2)*200*dt
	if love.keyboard.isDown('up') then
		nekochan.y = nekochan.y - 200*dt
	end
	if love.keyboard.isDown('down') then
		nekochan.y = nekochan.y + 200*dt
	end
	--]]
	if love.keyboard.isDown('left') then
		grinch.position = grinch.position - grinch.speed*dt
	end
	if love.keyboard.isDown('right') then
		grinch.position = grinch.position + grinch.speed*dt
	end
	
	--nekochan:update(dt)
	
        --get the size of our window
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
      
	-- Update clouds, iterating backwards for safe removal of off-screen ones.
	for k=#clouds,1,-1 do
		local c = clouds[k]
		c.x = c.x + c.s * dt
		if c.x > width then
			table.remove(clouds, k)
		end
	end

	try_spawn_cloud(dt)
	
        --get the top coordinate for the grinch
        grinch["top"] = height - grinch.height
end

function love.draw()
        --draw the clouds first, they are in the background
	for k, c in ipairs(clouds) do
		love.graphics.draw(cloud, c.x, c.y)
	end
	
	love.graphics.draw(grinch.image, grinch.position, grinch.top)
	--nekochan:render()
	
end

function love.keypressed(k)
	if k == "r" then
		love.filesystem.load("main.lua")()
	end
end

--[[
nekochan = {
	x = 400, 
	y = 250, 
	a = 0
}

function nekochan:update(dt)
		self.a = self.a + 10 * dt	
end

function nekochan:render()
	love.graphics.draw(body, self.x, self.y, 0, 1, 1, 64, 64)
	love.graphics.draw(face, self.x, self.y + math.sin(self.a/5) * 3, 0, 1, 1, 64, 64)
	local r = 1 + math.sin(self.a*math.pi/20)
	for i = 1,10 do
		love.graphics.draw(ear, self.x, self.y, (i * math.pi*2/10) + self.a/10, 1, 1, 16, 64+10*r)
	end
	
end
--]]
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
