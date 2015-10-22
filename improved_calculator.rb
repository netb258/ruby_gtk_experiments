require "gtk3"

#This class performs mathematical operations in a queue
class QueueCalculator
  def initialize
    @operator_queue = []
    @number_queue = []
  end

  def add_operation(opp)
    @operator_queue.push(opp)
  end

  def add_number(num)
    @number_queue.push(num)
  end

  def clear_operations
    @operator_queue = []
  end

  def clear_numbers
    @number_queue = []
  end

  def calculate
    return 0 if @operator_queue.size == 0 or @number_queue.size <= 1
    result = @number_queue[0].send(@operator_queue.pop, @number_queue.pop)
    @number_queue[0] = result
    return result
  end
end

Gtk.init

calculator = Gtk::Window.new
internal_calculator = QueueCalculator.new
display = Gtk::Entry.new.set_can_focus(false)
should_clear_screen = false
last_operator = :none

#should be set to true if the buttons from 0 to 9 are clicked.
num_button_pressed = false

do_calculation = lambda do |operator|
  if num_button_pressed == true and operator != :none
    internal_calculator.add_operation(operator)
    internal_calculator.add_number(display.text.to_f)
    display.set_text(internal_calculator.calculate.to_s)
    should_clear_screen = true
    num_button_pressed = false
  end
end

pixels_between_children = 2
vbox = Gtk::Box.new(:vertical, pixels_between_children)
vbox.pack_start(display, :expand => false, :fill => false, :padding => 0)

grid = Gtk::Grid.new
grid.set_property("row-homogeneous", true)
grid.set_property("column-homogeneous", true)

#Create buttons:

button_clear    = Gtk::Button.new(:label => "Clear all")
button_cls      = Gtk::Button.new(:label => "Clear screen")

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
  internal_calculator.clear_operations
  internal_calculator.clear_numbers
end

button_plus.signal_connect("clicked") do
  if last_operator != :none
    do_calculation.call(last_operator)
  else
    do_calculation.call(:+)
  end
  last_operator = :+
end

button_minus.signal_connect("clicked") do
  if last_operator != :none
    do_calculation.call(last_operator)
  else
    do_calculation.call(:-)
  end
  last_operator = :-
end

button_multiply.signal_connect("clicked") do
  if last_operator != :none
    do_calculation.call(last_operator)
  else
    do_calculation.call(:*)
  end
  last_operator = :*
end

button_divide.signal_connect("clicked") do
  if last_operator != :none
    do_calculation.call(last_operator)
  else
    do_calculation.call(:/)
  end
  last_operator = :/
end

button_dot.signal_connect("clicked") do
  display.set_text(display.text + ".")
end

button_equals.signal_connect("clicked") do
  if num_button_pressed 
    do_calculation.call(last_operator)
    last_operator = :none
  end
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
      num_button_pressed = true
    end
  end.call(i)
end

#Show the calculator:
calculator.set_default_size(400, 300)
calculator.set_window_position(:center)
calculator.show_all

Gtk.main
