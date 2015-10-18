require "gtk3"

Gtk.init

calculator = Gtk::Window.new
display = Gtk::Entry.new.set_can_focus(false)

#The calculator only needs these 4 variables
accumulator1 = nil
accumulator2 = nil
operator = ""
should_clear_screen = false

calculate = lambda do |&opp|
  #If accumulator1 is empty, then this is the first operation in line
  #In that case, just fill accumulator1 with the number on the screen and clear the screen
  if accumulator1 == nil
    accumulator1 = display.text.to_f
    display.set_text("")
  #If accumulator1 is not empty, then we actually perform a calculation
  else
    accumulator2 = display.text.to_f
    result = opp.call(accumulator1, accumulator2)
    display.set_text(result.to_s)
    accumulator1 = result
    accumulator2 = nil
    should_clear_screen = true
  end
end

do_operation = lambda do
  if operator == "+"
    calculate.call do |num1, num2|
      num1 + num2
    end
  elsif operator == "-"
    calculate.call do |num1, num2|
      num1 - num2
    end
  elsif operator == "*"
    calculate.call do |num1, num2|
      num1 * num2
    end
  elsif operator == "/"
    calculate.call do |num1, num2|
      num1 / num2
    end
  end
  should_clear_screen = true
end

pixels_between_children = 2
vbox = Gtk::Box.new(:vertical, pixels_between_children)
vbox.pack_start(display, :expand => false, :fill => false, :padding => 0)

grid = Gtk::Grid.new
grid.set_property("row-homogeneous", true)
grid.set_property("column-homogeneous", true)

#Create buttons:

button_clear    = Gtk::Button.new(:label => "Clear all")
button_cls    = Gtk::Button.new(:label => "Clear screen")

button7         = Gtk::Button.new(:label => "7")
button8         = Gtk::Button.new(:label => "8")
button9         = Gtk::Button.new(:label => "9")
button_divide   = Gtk::Button.new(:label => "/")

button4         = Gtk::Button.new(:label => "4")
button5         = Gtk::Button.new(:label => "5")
button6         = Gtk::Button.new(:label => "6")
button_multiply = Gtk::Button.new(:label => "*")

button1         = Gtk::Button.new(:label => "1")
button2         = Gtk::Button.new(:label => "2")
button3         = Gtk::Button.new(:label => "3")
button_minus    = Gtk::Button.new(:label => "-")

button0         = Gtk::Button.new(:label => "0")
button_dot      = Gtk::Button.new(:label => ".")
button_equals   = Gtk::Button.new(:label => "=")
button_plus     = Gtk::Button.new(:label => "+")

#Add buttons to the calculator:

grid.attach(button_clear, 0, 0, 2, 1)
grid.attach(button_cls, 2, 0, 2, 1)

grid.attach(button7, 0, 1, 1, 1)
grid.attach(button8, 1, 1, 1, 1)
grid.attach(button9, 2, 1, 1, 1)
grid.attach(button_divide, 3, 1, 1, 1)

grid.attach(button4, 0, 2, 1, 1)
grid.attach(button5, 1, 2, 1, 1)
grid.attach(button6, 2, 2, 1, 1)
grid.attach(button_multiply, 3, 2, 1, 1)

grid.attach(button1, 0, 3, 1, 1)
grid.attach(button2, 1, 3, 1, 1)
grid.attach(button3, 2, 3, 1, 1)
grid.attach(button_minus, 3, 3, 1, 1)

grid.attach(button0, 0, 4, 1, 1)
grid.attach(button_dot, 1, 4, 1, 1)
grid.attach(button_equals, 2, 4, 1, 1)
grid.attach(button_plus, 3, 4, 1, 1)

vbox.pack_start(grid, :expand => true, :fill => true, :padding => 0)
calculator.add(vbox)
calculator.set_title("Calculator")

#Handle all events:

calculator.signal_connect("destroy") do
  Gtk.main_quit
end

button_cls.signal_connect("clicked") do
  display.set_text("")
end

button_clear.signal_connect("clicked") do
  accumulator1 = nil
  accumulator2 = nil
  display.set_text("")
end

button_plus.signal_connect("clicked") do
  #These comments apply to -, / and * as well
  #Try to queued up + as the next operation
  operator = "+" if operator == "" #Ensure that any previously queued up operation is not overriden by +
  do_operation.call #Perform the next queued up operation
  operator = "+" #Queued up + to be the next opperation
end

button_minus.signal_connect("clicked") do
  operator = "-" if operator == ""
  do_operation.call
  operator = "-"
end

button_multiply.signal_connect("clicked") do
  operator = "*" if operator == ""
  do_operation.call
  operator = "*"
end

button_divide.signal_connect("clicked") do
  operator = "/" if operator == ""
  do_operation.call
  operator = "/"
end

button_dot.signal_connect("clicked") do
  display.set_text(display.text + ".")
end

button_equals.signal_connect("clicked") do
  do_operation.call
  operator = ""
  accumulator1 = nil
  accumulator2 = nil
end

for i in 0..9
  lambda do |iter|
    eval("button" + iter.to_s).signal_connect("clicked") do
      if should_clear_screen == false
        display.set_text(display.text + iter.to_s)
      else
        display.set_text(iter.to_s)
        should_clear_screen = false
      end
    end
  end.call(i)
end

#Show the calculator:
calculator.set_default_size(400, 300)
calculator.set_window_position(:center)
calculator.show_all

Gtk.main
