require './validator.rb'

class Control
  def run
    while true do
      puts "Type in file name, example: 'u1', 'u2', or 'u3'. Type 'quit' to quit."
      file = gets.chomp
      if file.casecmp("Quit") == 0
        puts "Quitting..."
        exit
      else
        before = Time.now.utc
        puts "#{before}"
        puts "Processing file #{file}..."
        v = Validator.new(file)
        v.validate
        after = Time.now.utc
        puts "#{after}"
        puts "This took #{after - before} seconds!"
      end
    end
  end
  c = Control.new
  c.run
end
