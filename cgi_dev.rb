#!/usr/bin/ruby

require 'cgi'
cgi = CGI.new

puts cgi.header
puts "<html><body>This is a test</body></html>"
h = cgi.params  # =>  {"FirstName"=>["Spencer"],"LastName"=>["Peloquin"]}
h['FirstName']  # =>  ["Spencer"]
h['LastName']   # =>  ["Peloquin"]
cgi.keys   # =>  ["FirstName", "LastName"]
