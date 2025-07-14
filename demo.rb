#!/usr/bin/env ruby

# Demo script showing the SignalWire Challenge API functionality
require 'json'
require 'time'

puts "SignalWire Coding Challenge - API Demo"
puts "=" * 50

# Simulate the API controller logic
class TicketsAPI
  def initialize
    @tickets = []
    @tags = {}
    @ticket_id_counter = 1
  end
  
  def create_ticket(params)
    # Validate payload
    errors = validate_payload(params)
    
    if errors.any?
      return { status: 422, body: { errors: errors } }
    end
    
    # Create ticket
    ticket = {
      id: @ticket_id_counter,
      user_id: params['user_id'].to_i,
      title: params['title'],
      received_at: Time.now.iso8601
    }
    
    @tickets << ticket
    @ticket_id_counter += 1
    
    # Process tags
    if params['tags'] && params['tags'].is_a?(Array)
      params['tags'].each do |tag_name|
        increment_tag_count(tag_name)
      end
    end
    
    # Get highest count tag for webhook
    highest_tag = get_highest_count_tag
    webhook_data = nil
    if highest_tag
      webhook_data = {
        tag: highest_tag[:name],
        count: highest_tag[:count],
        timestamp: Time.now.iso8601
      }
    end
    
    {
      status: 201,
      body: {
        message: 'Ticket created successfully',
        ticket_id: ticket[:id]
      },
      webhook_data: webhook_data
    }
  end
  
  def get_tickets
    @tickets
  end
  
  def get_tags
    @tags
  end
  
  private
  
  def validate_payload(params)
    errors = []
    
    errors << 'user_id is required' if params['user_id'].nil? || params['user_id'].to_s.strip.empty?
    errors << 'title is required' if params['title'].nil? || params['title'].to_s.strip.empty?
    
    if params['user_id'] && !params['user_id'].to_s.match?(/\A\d+\z/)
      errors << 'user_id must be a number'
    end
    
    if params['tags']
      unless params['tags'].is_a?(Array)
        errors << 'tags must be an array'
      else
        if params['tags'].length >= 5
          errors << 'tags must be fewer than 5'
        end
      end
    end
    
    errors
  end
  
  def increment_tag_count(tag_name)
    normalized_name = tag_name.to_s.strip.downcase
    return if normalized_name.empty?
    
    @tags[normalized_name] = (@tags[normalized_name] || 0) + 1
  end
  
  def get_highest_count_tag
    return nil if @tags.empty?
    
    highest = @tags.max_by { |name, count| count }
    { name: highest[0], count: highest[1] }
  end
end

# Create API instance
api = TicketsAPI.new

# Test cases
test_requests = [
  {
    name: "Valid request with tags",
    payload: { "user_id" => 1234, "title" => "Bug report", "tags" => ["bug", "urgent"] }
  },
  {
    name: "Valid request without tags",
    payload: { "user_id" => 5678, "title" => "Feature request" }
  },
  {
    name: "Another request with overlapping tags",
    payload: { "user_id" => 9999, "title" => "Another bug", "tags" => ["bug", "frontend"] }
  },
  {
    name: "Request with case-insensitive tags",
    payload: { "user_id" => 1111, "title" => "UI Issue", "tags" => ["BUG", "Frontend"] }
  },
  {
    name: "Invalid - missing user_id",
    payload: { "title" => "Missing user", "tags" => ["test"] }
  },
  {
    name: "Invalid - too many tags",
    payload: { "user_id" => 2222, "title" => "Too many tags", "tags" => ["tag1", "tag2", "tag3", "tag4", "tag5"] }
  }
]

# Process each request
test_requests.each_with_index do |test, index|
  puts "\n#{index + 1}. #{test[:name]}"
  puts "   Request: #{test[:payload].to_json}"
  
  response = api.create_ticket(test[:payload])
  
  puts "   Status: #{response[:status]}"
  puts "   Response: #{response[:body].to_json}"
  
  if response[:webhook_data]
    puts "   Webhook: Would send to webhook URL with data: #{response[:webhook_data].to_json}"
  end
  
  if response[:status] == 201
    puts "   ✓ SUCCESS"
  else
    puts "   ⚠ VALIDATION ERROR"
  end
end

# Show final state
puts "\n" + "=" * 50
puts "FINAL STATE"
puts "=" * 50

puts "\nAll Tickets:"
api.get_tickets.each do |ticket|
  puts "  ID: #{ticket[:id]}, User: #{ticket[:user_id]}, Title: '#{ticket[:title]}', Received: #{ticket[:received_at]}"
end

puts "\nTag Counts (case-insensitive):"
api.get_tags.sort_by { |name, count| -count }.each do |name, count|
  puts "  #{name}: #{count}"
end

highest = api.send(:get_highest_count_tag)
if highest
  puts "\nHighest Count Tag: #{highest[:name]} (#{highest[:count]} occurrences)"
  puts "This would be sent in webhook requests."
end

puts "\n" + "=" * 50
puts "API ENDPOINTS SUMMARY"
puts "=" * 50
puts "POST /api/v1/tickets - Create a ticket"
puts "  - Validates user_id (required, numeric)"
puts "  - Validates title (required)"
puts "  - Validates tags (optional, array, < 5 items)"
puts "  - Stores ticket with timestamp"
puts "  - Increments tag counts (case-insensitive)"
puts "  - Sends webhook with highest count tag"
puts "  - Returns 201 on success, 422 on validation error"

puts "\nExample curl command:"
puts 'curl -X POST http://localhost:3000/api/v1/tickets \\'
puts '  -H "Content-Type: application/json" \\'
puts '  -d \'{"user_id": 1234, "title": "My title", "tags": ["tag1", "tag2"]}\''

puts "\nAll requirements from the challenge have been implemented!"
