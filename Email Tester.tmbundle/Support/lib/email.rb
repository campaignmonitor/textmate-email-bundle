#!/usr/bin/env ruby

# To use this script you need to install 4 extra gems.
# gem install mailfactory
# gem install tlsmail
# gem install hpricot
# gem install tamtam

require 'rubygems'
require 'open-uri'
require 'net/smtp'
require 'mailfactory'
require 'tlsmail'
require 'hpricot'
require 'tamtam'

from = ARGV[0]
to = ARGV[1]
server = ARGV[2]
port = ARGV[3]
ssl = ARGV[4]
tmp = ARGV[5]
username = ARGV[6]
password = ARGV[7]

##
# Take the temp output from TextMate and create inline CSS
##

stylesheet = File.open(tmp, "r").read.match(/href=[\"']?([^> \"']*.css)/i).to_a[1]


if stylesheet.nil?
   inlined = TamTam.inline(:document => File.read(tmp))
else
   inlined = TamTam.inline(
      :css => File.read("#{ENV['TM_DIRECTORY']}/#{stylesheet}"),
      :body => File.read(tmp)
   )
end

File.open(tmp, 'w') do |dump|
   dump.puts inlined
end

##
# Pull title out of your test email and make it the subject
##

title = File.open(tmp, "r").read.match(/<title>([^<>]*)<\/title>/i).to_a[1].strip

##
# Get the contens of your TextMate document
##

html = []
File.new(tmp, "r").each { |line| html << line }

##
# Create and send email
##

mail = MailFactory.new()
mail.to = "#{to}"
mail.from = "#{from}"
mail.subject = "#{title}"
mail.rawhtml = "#{html}"
mail.text = "This is the plain text version."

if ssl == "false"
   Net::SMTP.start(server, port, 'helo.local', username, password, :login) do |smtp|
      smtp.send_message(mail.to_s(), "#{from}", "#{to}")
   end
else
   Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
   Net::SMTP.start(server, port, 'helo.local', username, password, :login) do |smtp|
      smtp.send_message(mail.to_s(), "#{from}", "#{to}")
   end
end



