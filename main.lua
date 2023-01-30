push = require "push"
class = require "class"

window_width = 1280
window_height = 720

virtual_width = 432
virtual_height = 243

require "Paddle"
require "Ball"

paddle_Speed = 200

function love.load()
	math.randomseed(os.time())

	love.graphics.setDefaultFilter("nearest", "nearest")

	Font = love.graphics.newFont("font_0.ttf", 12)
	scoreFont = love.graphics.newFont("font_1.ttf", 32)

	-- Implementing Sounds
	sounds = {["Paddle_Hit"] = love.audio.newSource("sounds/Paddle_Hit.wav", "static"),
		    ["Wall_Hit"] = love.audio.newSource("sounds/Wall_Hit.wav", "static"),
		    ["Score"] = love.audio.newSource("sounds/Score.wav", "static")}

	push:setupScreen(virtual_width, virtual_height, window_width, window_height,
		{fullscreen = false,
		 resizable = true,
		 vsync = true})

	text = "Welcome to Pong!"

	player1 = Paddle(10, 50, 5, 20)							-- player 1 position
	player2 = Paddle(virtual_width-15, virtual_height-50, 5, 20)		-- player 2 position

	servingPlayer = 1

	player1Score = 0
	player2Score = 0

	ball = Ball(virtual_width/2-2, virtual_height/2-2, 4, 4)

	gameState = "start"
	love.window.setTitle("Ping Pong ~ Reboot")
end

function love.resize(w, h)
	push:resize(w, h)
end

function love.update(dt)

	if gameState == "serve" then
		ball.dy = math.random(-50, 50)
		if servingPlayer == 1 then
			ball.dx = math.random(140,200)
		else
			ball.dx = -math.random(140,200)
		end

	elseif gameState == "play" then

		-- Detect the ball collision with paddles and reverse the dx if the collision is true and
		-- slightly increasing it and then altering the dy based on the position of collision

		if ball:collides (player1) then
			ball.dx = -ball.dx * 1.03 -- x3 times of the speed
			ball.x = player1.x + 5

			-- keep velocity going in the same direction, but randomize it
			if ball.dy <= 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end

			sounds["Paddle_Hit"]:play()
		end
	
		if ball : collides (player2) then
			ball.dx = -ball.dx * 1.03
			ball.x = player2.x - 4

			if ball.dy <= 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end

			sounds["Paddle_Hit"]:play()
		end

		-- detect upper and lower screen boundary collision and reverse the dy if the collision is true
		if ball.y <=0 then
			ball.y = 0
			ball.dy = -ball.dy
			
			sounds["Wall_Hit"]:play()
		end
		if ball.y >= virtual_height - 4 then
			ball.y = virtual_height - 4
			ball.dy = -ball.dy
			
			sounds["Wall_Hit"]:play()
		end
	end

	if ball.x < 0 then
		
		servingPlayer = 1
		player2Score = player2Score + 1
		
		sounds["Score"]:play()

		if player2Score == 10 then
		
			WinningPlayer = 2
			gameState = "done"
		else
			gameState = "serve"
		end
		ball:reset()
	end

	if ball.x >virtual_width then

		servingPlayer = 2
		player1Score = player1Score + 1
		
		sounds["Score"]:play()

		if player1Score == 10 then
			WinningPlayer = 1
			gameState = "done"
		else
			gameState = "serve"
		end
		ball:reset()
	end

	if ball.x < player2.x-4 then
		player1.y = ball.y
	else
		player1.dy = 0
	end

	if love.keyboard.isDown("up") then
		player2.dy = -paddle_Speed
	elseif love.keyboard.isDown("down") then
		player2.dy = paddle_Speed
	else
		player2.dy = 0
	end

	if gameState == "play" then
		ball:update(dt)
	end
	player1:update(dt)
	player2:update(dt)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "enter" or key == "return" then
		if gameState == "start" then
			gameState = "serve"
		elseif gameState == "serve" then
			gameState = "play"
		elseif gameState == "done" then
			gameState = "serve"

			ball:reset()
			player1Score = 0
			player2Score = 0

			if WinningPlayer == 1 then
				servingPlayer = 2
			else
				servingPlayer = 1
			end
		end
	end
end

function love.draw()
	push:apply("start")

	love.graphics.clear(40/255, 45/255, 52/255, 0) -- sets background color, 0 mades the background black since its about opacity to check what it truly shows use 255/255
									-- 1 in place of 0 gives white background
	love.graphics.setFont(Font)
	love.graphics.setColor(0, 255, 0)	    		-- sets font color
	love.graphics.printf(text .. "\n1 Player but Hard Mode", 0, 10, virtual_width, "center")

	DisplayDash()

	DisplayScore()

	love.graphics.setColor(0, 255, 0)	   
	player1:render()				-- left paddle  (mode, h_position, v_position, width, height)

	love.graphics.setColor(255, 0, 0)	 
	ball:render()				-- ball Position

	love.graphics.setColor(0, 255, 0)	 
	player2:render()	-- right paddle

	displayFPS()

	push:apply("end")
end

function displayFPS()
	love.graphics.setFont(Font)
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.print("FPS : ".. tostring(love.timer.getFPS()), 10, 10)
end

function DisplayDash()
	DashFont = love.graphics.newFont("font_0.ttf", 12)
	love.graphics.setFont(DashFont)
	if gameState == "start" then
		love.graphics.printf("\nREADY!", 0, 20, virtual_width, "center")
	elseif gameState == "serve" then
		love.graphics.printf("\nPlayer " .. tostring(servingPlayer) .. "'s Serve", 0, 20, virtual_width, "center")
		love.graphics.printf("\nPress ENTER to Serve", 0, 30, virtual_width, "center")
	elseif gameState == "play" then
		love.graphics.printf("\nPLAY!", 0, 20, virtual_width, "center")
	elseif gameState == "done" then
		love.graphics.printf("\nPlayer " .. tostring(WinningPlayer) .. " Wins!", 0, 20, virtual_width, "center")
		love.graphics.printf("\nPress ENTER to Restart", 0, 30, virtual_width, "center")
	end
end

function DisplayScore()
	love.graphics.setFont(scoreFont)
	love.graphics.setColor(255, 0, 0)
	love.graphics.print(tostring(player1Score), virtual_width/2-virtual_width/4, virtual_height/3)
	love.graphics.print(tostring(player2Score), virtual_width/2+virtual_width/4, virtual_height/3)
end