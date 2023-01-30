Paddle = class{}

function Paddle : init(x, y, width, height)		-- Initializing the paddle. it used to create the paddle
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.dy = 0							-- stting the speed of paddle is zero i.e., paddle at rest
end

function Paddle : update(dt)
	if self.y < 0 then
		self.y = math.max(0, self.y + self.dy *dt)
	else
		self.y = math.min(virtual_height-self.height, self.y + self.dy * dt)
	end
end

function Paddle : render()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end