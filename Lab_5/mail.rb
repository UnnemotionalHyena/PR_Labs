require 'net/imap'
require 'net/smtp'
require 'pry'
require "base64"
require "tlsmail"
require 'io/console'

def decode_string(subject)
  if subject =~ /=?utf-8?B?/
    subject = subject.gsub("=?utf-8?B?", "")
    decoded = Base64.decode64(subject[0..-2])
    decoded.encoding
    decoded = decoded.force_encoding('UTF-8')
    return decoded
  else
    return subject
  end
end

imap = Net::IMAP.new('imap.mail.ru', ssl: true)

puts "Enter your email: "
user_name = gets.chomp

puts "Enter your password: "
user_password = STDIN.noecho(&:gets).chomp!

imap.login(user_name, user_password)

imap.examine('INBOX')
puts "Number of unread messages: #{imap.search(["NOT", "SEEN"]).size}"

puts "Enter last N received messages:"
n_receved = gets.chomp


all_messages = imap.search(["ALL"])
messages_size = all_messages.size

n_receved.to_i.times do |index|
  envelope = imap.fetch(messages_size - index, "ENVELOPE")[0].attr["ENVELOPE"]
  subject  = envelope.subject
  subject  = decode_string(subject)
  puts "Subject: #{subject}"
  puts "Sender: #{decode_string(envelope.from[0].name)}"
  puts "Date: #{envelope.date}"
end


msgstr = <<END_OF_MESSAGE
From: Your Name <oksurdu@mail.ru>
To: Destination Address <okdan96@gmail.com>
Subject: test message
Date: Sat, 23 Jun 2001 16:26:43 +0900
Message-Id: <unique.message.id.string@example.com>

This is a test message.
END_OF_MESSAGE

Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)

Net::SMTP.start('smtp.mail.ru', 587, 'gmail.com', user_name, user_password, :login) do |smtp|
  smtp.send_message(msgstr, user_name, "okdan96@gmail.com")
end





