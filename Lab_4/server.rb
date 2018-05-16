require 'socket'
require 'levenshtein'

@connection_name = {}
@commands_info   = {
  "/help"           => "Shows all available commands",
  "/hello"          => "Prints Hello",
  "/hello <string>" => "Prints Hello + <string>; Ex: Hello mrs Eminem",
  "/time"           => "Shows server local time; Ex: 2018-04-24 21:51:39 +0300",
  "/coin"           => "Flips the coin randomly; Ex: Heads",
  "/quit"           => "Ends the session and deletes the username"
}

def show_commands
  string = ""
  @commands_info.each do |command|
    string += "#{command.first.ljust(16)} #{command.last.rjust(10)} \n"
  end
  string
end


def hello_world(string=nil)
  string ? "Hello #{string}" : "Hello"
end

def current_time
  Time.now().to_s
end

def flip_coin
  rand(0..1) == 0 ? "Heads" : "Tails"
end

def levenshtein_distance(message)
  distances = {}
  @commands_info.each_key do |command|
    distances[command] = Levenshtein.distance(message, command)
  end
  min_distance = distances.values.sort.first
  min_distance < 2 ? distances.key(min_distance) : ""
end

commands = {
  "/help"  => method(:show_commands),
  "/hello" => method(:hello_world),
  "/time"  => method(:current_time),
  "/coin"  => method(:flip_coin)
}

server = TCPServer.open("localhost", 8090)
loop do
  client = server.accept
  Thread.start(client) do |connection|
    connection.puts "Please enter your username to establish a connection..."
    connection.puts "Username: "
    loop do
      name = connection.gets.chomp.to_sym
      if name.empty?
        connection.puts "Username: "
        next
      end
      if @connection_name.values.include? name
        connection.puts "This username already exist"
        connection.puts "quit session"
        connection.kill self
      else
        @connection_name[connection] = name
      end
      puts "Connection established #{@connection_name[connection]}"
      connection.puts "Connection established"
      break
    end
    loop do 
      message = connection.gets.chomp
      next if message.empty?

      message = message.split(" ")

      if @commands_info.keys.include? message[0]
        if message[0] == "/quit"
          connection.puts "quit session"
          puts "Connection #{@connection_name[connection]} deleted"
          @connection_name.delete(connection)
        elsif message.size > 1
          connection.puts(commands[message[0]].call(message[1..-1].join(" ")))
        else
          connection.puts(commands[message[0]].call)
        end
      elsif @commands_info.keys.include? levenshtein_distance(message[0])
        connection.puts "Did you mean: #{levenshtein_distance(message[0])}"
      else
        connection.puts("Invalid command")
      end
    end
  end
end.join
