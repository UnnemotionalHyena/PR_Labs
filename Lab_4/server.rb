require 'socket'

connection_name = []

server = TCPServer.open("localhost", 8090)
loop do
  client = server.accept
  Thread.start(client) do |connection|
    if connection_name.include? connection.gets.chomp.to_sym
      connection.puts "This username already exist"
      connection.puts "quit session"
      return
    else
      connection_name << connection.gets.chomp.to_sym
    end
    puts "Connection established #{connection_name}"
    loop do 
      message = connection.gets.chomp
      if message == "/help"
        connection.puts "#{connection_name} : the commands are: \n /help \n /start"
      else
        connection.puts message
      end
    end
  end
end