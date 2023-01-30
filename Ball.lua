Ball = class{}

function Ball : init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height

	self.dy = math.random(2) == 1 and -100 or 100
	self.dx = math.random(-50, 50)
end

function Ball : reset()
	self.x = virtual_width/2-2
	self.y = virtual_height/2-2

	self.dx = math.random(2) == 1 and -100 or 100
	self.dy = math.random(-50, 50)
end

function Ball : update(dt)
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
end

function Ball : collides(Paddle)
	if self.x > Paddle.x + Paddle.width or Paddle.x > self.x + self.width then
		return false
	end

	if self.y > Paddle.y + Paddle.height or Paddle.y >self.y + self.height then
		return false
	end

	return true
end

function Ball : render()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end