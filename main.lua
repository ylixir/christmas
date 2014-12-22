-------------------------------------------------
-- LOVE: Passing Clouds Demo								
-- Website: http://love.sourceforge.net			
-- Licence: ZLIB/libpng									
-- Copyright (c) 2006-2009 LOVE Development Team
-------------------------------------------------

function love.load()
	-- The various images used.
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
end

function love.update(dt)
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
        --move the grinch as necessary
	if love.keyboard.isDown('left') or love.keyboard.isDown('h') then
	  grinch:left(dt)
	end
	if love.keyboard.isDown('right') or love.keyboard.isDown('l') then
	  grinch:right(dt)
	end
end

function love.draw()
        --draw the clouds first, they are in the background
	for k, c in ipairs(clouds) do
		love.graphics.draw(cloud, c.x, c.y)
	end
	
	love.graphics.draw(grinch.image, grinch.position, grinch.top)
	love.graphics.draw(grinch.gun, grinch.position, grinch.top)
	--nekochan:render()
	
end

function love.keypressed(k)
	if k == "r" then
		love.filesystem.load("main.lua")()
	end
end

grinch = {
  speed  = 200,
  width  = 180,
  height = 204,
  left_offset = 18,
  right_offset = 112,
  position = 18
}

function grinch:left(dt)
  grinch.position = grinch.position - grinch.speed*dt
  if grinch.position < 0 - grinch.left_offset then
    grinch.position = 0 - grinch.left_offset
  end
end

function grinch:right(dt)
  grinch.position = grinch.position + grinch.speed*dt
  if grinch.position > width - grinch.right_offset then
    grinch.position = width - grinch.right_offset
  end
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
