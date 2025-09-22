#!/usr/bin/env ruby
# Test script for the user API endpoints

require 'net/http'
require 'json'
require 'uri'

class UserAPITester
  BASE_URL = 'http://localhost:3000/api/v1'

  def initialize
    @token = nil
  end

  def test_login_and_profile_update
    puts "Testing User API endpoints..."

    # First, we need to authenticate
    puts "\n1. Testing authentication flow..."

    # Request magic link
    response = make_request(:post, '/auth/request_magic_link', {
      email: 'test@example.com'
    })

    if response['success']
      puts "✓ Magic link requested successfully"

      # In a real scenario, you'd get the code from email or console
      # For testing, let's check if we can get the auth code from the database
      puts "\nNote: In a real scenario, you would get the verification code from email."
      puts "For testing, you need to check the database or logs for the auth code."
      puts "Then use the code to verify and get a JWT token."

      false # Can't continue without the verification code
    else
      puts "✗ Failed to request magic link: #{response['message']}"
      false
    end
  end

  def test_with_existing_token(token)
    @token = token
    puts "\nTesting user profile endpoints with token..."

    # Test get profile
    puts "\n2. Testing GET /users/profile..."
    response = make_authenticated_request(:get, '/users/profile')

    if response['success']
      puts "✓ Profile retrieved successfully"
      puts "User data: #{response['data']}"

      # Test update profile
      puts "\n3. Testing PATCH /users/profile..."
      update_data = {
        user: {
          first_name: "John",
          last_name: "Doe",
          profession: "Tailors / Dressmakers",
          business_name: "John's Tailoring",
          business_address: "123 Fashion Street",
          skills: [ "Fashion Designing", "Bespoke Tailoring" ]
        }
      }

      response = make_authenticated_request(:patch, '/users/profile', update_data)

      if response['success']
        puts "✓ Profile updated successfully"
        puts "Updated data: #{response['data']}"
        true
      else
        puts "✗ Failed to update profile: #{response['message']}"
        puts "Errors: #{response['errors']}" if response['errors']
        false
      end
    else
      puts "✗ Failed to get profile: #{response['message']}"
      false
    end
  end

  private

  def make_request(method, endpoint, data = nil)
    uri = URI("#{BASE_URL}#{endpoint}")
    http = Net::HTTP.new(uri.host, uri.port)

    case method
    when :get
      request = Net::HTTP::Get.new(uri)
    when :post
      request = Net::HTTP::Post.new(uri)
    when :patch
      request = Net::HTTP::Patch.new(uri)
    end

    request['Content-Type'] = 'application/json'
    request.body = data.to_json if data

    response = http.request(request)
    JSON.parse(response.body)
  rescue StandardError => e
    { 'success' => false, 'message' => e.message }
  end

  def make_authenticated_request(method, endpoint, data = nil)
    uri = URI("#{BASE_URL}#{endpoint}")
    http = Net::HTTP.new(uri.host, uri.port)

    case method
    when :get
      request = Net::HTTP::Get.new(uri)
    when :post
      request = Net::HTTP::Post.new(uri)
    when :patch
      request = Net::HTTP::Patch.new(uri)
    end

    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{@token}" if @token
    request.body = data.to_json if data

    response = http.request(request)
    JSON.parse(response.body)
  rescue StandardError => e
    { 'success' => false, 'message' => e.message }
  end
end

if __FILE__ == $0
  tester = UserAPITester.new

  puts "User API Test Script"
  puts "==================="
  puts "Make sure the Rails server is running on localhost:3000"
  puts ""

  # Test authentication flow
  success = tester.test_login_and_profile_update

  unless success
    puts "\nTo test the user profile endpoints, you need a valid JWT token."
    puts "You can:"
    puts "1. Use the Rails console to create a user and generate a token"
    puts "2. Use the authentication endpoints to get a token"
    puts "3. Pass a token directly to test_with_existing_token method"
    puts ""
    puts "Example to get a token via Rails console:"
    puts "rails runner \"user = User.find_by(email: 'test@example.com') || User.create!(email: 'test@example.com'); puts JwtService.encode({user_id: user.id})\""
  end
end
