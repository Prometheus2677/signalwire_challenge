#!/usr/bin/env ruby

# Simple script to test the SignalWire API
require 'net/http'
require 'json'
require 'uri'

def create_ticket(user_id, title, tags = [])
  uri = URI('http://localhost:3000/api/v1/tickets')
  http = Net::HTTP.new(uri.host, uri.port)
  
  request = Net::HTTP::Post.new(uri)
  request['Content-Type'] = 'application/json'
  request.body = {
    user_id: user_id,
    title: title,
    tags: tags
  }.to_json
  
  response = http.request(request)
  
  puts "Creating ticket: #{title}"
  puts "Status: #{response.code}"
  puts "Response: #{response.body}"
  puts "-" * 50
  
  response
end

def get_debug_info(endpoint)
  uri = URI("http://localhost:3000/debug/#{endpoint}")
  response = Net::HTTP.get_response(uri)
  
  puts "#{endpoint.upcase}:"
  puts JSON.pretty_generate(JSON.parse(response.body))
  puts "-" * 50
end

puts "Testing SignalWire Challenge API"
puts "=" * 50

# Test valid tickets
create_ticket(1234, "Bug in login system", ["bug", "urgent"])
create_ticket(5678, "Add dark mode feature", ["feature", "ui"])
create_ticket(9999, "Performance issue", ["bug", "performance"])
create_ticket(1111, "Documentation update", ["docs"])

# Test validation errors
puts "\nTesting validation errors:"
create_ticket(nil, "Missing user_id", ["test"])
create_ticket("abc", "Invalid user_id", ["test"])
create_ticket(2222, "", ["test"])  # Empty title
create_ticket(3333, "Too many tags", ["tag1", "tag2", "tag3", "tag4", "tag5"])

# Show results
puts "\nFinal Results:"
puts "=" * 50
get_debug_info("tickets")
get_debug_info("tags")

puts "Visit http://localhost:3000/debug/tickets to see all tickets"
puts "Visit http://localhost:3000/debug/tags to see tag counts"
