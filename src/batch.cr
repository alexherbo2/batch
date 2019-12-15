require "option_parser"

struct Options
  property pick
  property map
  property drop
  property editor
  property confirm
  def initialize(@pick : String? = nil, @map : String? = nil, @drop : String? = nil, @editor = ENV["EDITOR"], @confirm = true)
  end
end

struct Command
  property name
  property body
  property arguments
  def initialize(@name : String, @body : String?, @arguments = [] of Array(String))
  end
end

macro version
  {{ `git describe --tags --always`.stringify }}
end

def main
  options = Options.new
  OptionParser.parse(ARGV) do |parser|
    parser.banner = "Usage: batch [arguments]"
    parser.on("-p COMMAND", "--pick=COMMAND", "Run command on unchanged elements") { |command| options.pick = command }
    parser.on("-m COMMAND", "--map=COMMAND", "Run command on modified elements") { |command| options.map = command }
    parser.on("-d COMMAND", "--drop=COMMAND", "Run command on deleted elements") { |command| options.drop = command }
    parser.on("--editor=COMMAND", %(Configure editor.  If command contains spaces, command must include "${@}" (including the quotes) to receive the argument list.)) { |command| options.editor = command }
    parser.on("--no-confirm", "Do not ask for confirmation") { options.confirm = false }
    parser.on("-v", "--version", "Display version number and quit") { puts version; exit }
    parser.on("-h", "--help", "Display a help message and quit") { puts parser; exit }
    parser.invalid_option do |flag|
      STDERR.puts "Error: Unknown option: #{flag}"
      STDERR.puts parser
      exit(1)
    end
  end
  if { options.pick, options.map, options.drop }.all? &.nil?
    options.pick = %(echo pick "$1")
    options.map = %(echo map "$1" → "$2")
    options.drop = %(echo drop "$1")
  end
  input = if STDIN.tty?
    if ARGV.empty?
      Dir.glob("*")
    else
      ARGV
    end
  else
    value = STDIN.each_line.to_a
    tty = File.new("/dev/tty")
    STDIN.reopen(tty)
    value
  end
  input_file = File.tempfile("input", ".txt") do |file|
    file.puts input.join('\n')
  end
  at_exit { input_file.delete }
  system(options.editor, { input_file.path })
  output = File.read_lines(input_file.path)
  if input.size != output.size
    STDERR.puts "Error: Cannot operate translation: Number of lines differs"
    exit(1)
  end
  pick = Command.new("pick", options.pick)
  map = Command.new("map", options.map)
  drop = Command.new("drop", options.drop)
  input.zip(output).each do |input, output|
    if input == output
      pick.arguments << [input]
    elsif output.empty?
      drop.arguments << [input]
    else
      map.arguments << [input, output]
    end
  end
  something_to_do = false
  shell_file = File.tempfile("output", ".sh") do |file|
    file.puts <<-'EOF'
    # This file will be executed when you close the editor.
    # Please double-check everything, clear the file to abort.
    EOF
    [pick, map, drop].each do |command|
      if command.body.nil? || command.arguments.empty?
        next
      end
      something_to_do = true
      # Add an empty line
      file.puts <<-EOF

      #{command.name}() {
        #{command.body}
      }
      EOF
      command.arguments.each do |arguments|
        arguments = arguments.map(&.shell_escape).join(" ")
        file.puts command.name + " " + arguments
      end
    end
  end
  at_exit { shell_file.delete }
  if ! something_to_do
    STDERR.puts "Nothing to do"
    exit
  end
  if options.confirm
    system(options.editor, { shell_file.path })
  end
  system("sh", { shell_file.path })
end

class String
  def shell_escape
    "'" + self.gsub("'", %('"'"')) + "'"
  end
end

main
