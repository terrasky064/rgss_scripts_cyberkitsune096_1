class Window_Ring_Command < Window_Base
 
  attr_accessor :index
 
  Turn_Frames = 20
 
  def initialize(x_pos, y_pos, commands, radius = 150.0)
    super(0, 0, 640, 480)
    @x_pos = x_pos
    @y_pos = y_pos
    @commands = commands
    @index = 0
    @moving = 0
    @radius = radius
    @radius = radius
    self.contents = Bitmap.new(width-32, height-32)
    self.opacity = 0
    refresh
  end
 
  def update
    super
    if @moving != 0
      refresh
    end
  end
 
  def refresh
    self.contents.clear
    if @moving != 0
      @moving = (Math.abs(@moving) - 1) * (@moving/Math.abs(@moving))
    end
    max_item = @commands.size
    pi_part = (2 * Math::PI) / max_item
    for i in 0...max_item
      x = (@radius * Math.sin((i * pi_part) + (@moving * (pi_part/Turn_Frames)))) + @x_pos
      x = x.to_i
      y = (@radius * Math.cos((i * pi_part) + (@moving * (pi_part/Turn_Frames)))) + @y_pos
      y = y.to_i
      draw_item(x, y, i)
    end
  end
 
  def draw_item(x, y, i)
    k = i + @index
    if k >= @commands.size
      k -= @commands.size
    end
    self.contents.draw_text(x, y, 150, 32, @commands[k])
  end
 
  def move_right
    @index += 1
    if @index >= @commands.size
      @index -= @commands.size
    end
    @moving += Turn_Frames
  end
 
  def move_left
    @index -= 1
    if @index < 0
      @index += @commands.size
    end
    @moving -= Turn_Frames
  end
 
  def moving?
    return @moving != 0
  end
 
end

module Math
 
  def self.abs(x)
    if x >= 0
      return x
    else
      return -1 * x
    end
  end
 
end