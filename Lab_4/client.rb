require 'socket'

socket = TCPSocket.open( "localhost", 8090 )

puts "Please enter your username to establish a connection..."

a = Thread.new do
  loop do
    message = $stdin.gets.chomp
    socket.puts message
  end
end

b = Thread.new do
  loop do
    response = socket.gets.chomp
    puts "#{response}"
    if response.eql?'quit'
      socket.close
      return
    end
  end
end

a.run
b.run

a.join
b.join
