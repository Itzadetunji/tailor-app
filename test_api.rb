#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

# Test script for Tailor App API
BASE_URL = 'http://localhost:3000'

def make_request(method, path, body = nil)
  uri = URI("#{BASE_URL}#{path}")
  http = Net::HTTP.new(uri.host, uri.port)

  case method.upcase
  when 'GET'
    request = Net::HTTP::Get.new(uri)
  when 'POST'
    request = Net::HTTP::Post.new(uri)
  when 'PATCH'
    request = Net::HTTP::Patch.new(uri)
  when 'DELETE'
    request = Net::HTTP::Delete.new(uri)
  end

  request['Content-Type'] = 'application/json'
  request.body = body.to_json if body

  response = http.request(request)

  puts "\n#{method} #{path}"
  puts "Status: #{response.code}"
  puts "Response: #{JSON.pretty_generate(JSON.parse(response.body))}" rescue puts "Response: #{response.body}"

  JSON.parse(response.body) rescue nil
end

puts "🧵 Testing Tailor App API"
puts "=" * 50

# Test 1: Get all custom fields
puts "\n1. Testing GET /api/v1/custom_fields"
make_request('GET', '/api/v1/custom_fields')

# Test 2: Create a new custom field
puts "\n2. Testing POST /api/v1/custom_fields"
custom_field_data = {
  custom_field: {
    field_name: "Test Custom Field #{Time.now.to_i}",
    field_type: "measurement"
  }
}
custom_field_response = make_request('POST', '/api/v1/custom_fields', custom_field_data)

# Test 3: Get all clients
puts "\n3. Testing GET /api/v1/clients"
make_request('GET', '/api/v1/clients')

# Test 4: Create a new client
puts "\n4. Testing POST /api/v1/clients"
client_data = {
  client: {
    name: "Test Client #{Time.now.to_i}",
    gender: "Male",
    measurement_unit: "inches",
    email: "test#{Time.now.to_i}@example.com",
    phone_number: "+1234567890",
    chest: 42.0,
    waist: 32.0,
    height: 72.0,
    shoulder: 18.0
  }
}
client_response = make_request('POST', '/api/v1/clients', client_data)

# Test 5: Update the client if creation was successful
if client_response && client_response['success']
  client_id = client_response['data']['data']['id']

  puts "\n5. Testing PATCH /api/v1/clients/#{client_id}"
  update_data = {
    client: {
      name: "Updated Test Client",
      chest: 44.0
    }
  }
  make_request('PATCH', "/api/v1/clients/#{client_id}", update_data)

  # Test 6: Get single client
  puts "\n6. Testing GET /api/v1/clients/#{client_id}"
  make_request('GET', "/api/v1/clients/#{client_id}")
end

# Test 7: Test measurement unit conversion
puts "\n7. Testing measurement unit conversion (inches to cm)"
cm_client_data = {
  client: {
    name: "CM Test Client #{Time.now.to_i}",
    gender: "Female",
    measurement_unit: "centimeters",
    email: "cmtest#{Time.now.to_i}@example.com",
    chest: 100.0,
    waist: 80.0
  }
}
make_request('POST', '/api/v1/clients', cm_client_data)

# Test 8: Test pagination
puts "\n8. Testing pagination"
make_request('GET', '/api/v1/clients?page=1&per_page=2')

# Test 9: Test validation errors
puts "\n9. Testing validation errors"
invalid_client = {
  client: {
    name: "A", # Too short
    gender: "Other", # Invalid
    measurement_unit: "meters" # Invalid
  }
}
make_request('POST', '/api/v1/clients', invalid_client)

puts "\n" + "=" * 50
puts "✅ API testing completed!"
puts "Check the server logs for any errors."
