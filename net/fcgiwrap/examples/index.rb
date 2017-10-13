#!/usr/bin/ruby
puts "HTTP/1.0 200 OK"
puts "Content-type: text/html\n\n"
puts "<html><HEAD><TITLE>Ruby script</TITLE></HEAD>"
puts "<BODY><PRE>"
puts "<div align=center><h1>A Ruby CGI index on fourth location with env variables</h1></div>"
system('env')

