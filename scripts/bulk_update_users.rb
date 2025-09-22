#!/usr/bin/env ruby
# Script to bulk update user information in the tailor-app database
# Usage: ruby scripts/bulk_update_users.rb

require_relative '../config/environment'

class BulkUserUpdater
  attr_reader :updated_count, :failed_count, :errors

  def initialize
    @updated_count = 0
    @failed_count = 0
    @errors = []
  end

  def update_all_users(updates = {})
    puts "Starting bulk update of users..."
    puts "Total users to process: #{User.count}"

    default_updates = {
      # Example default updates - customize as needed
      # profession: "Tailors / Dressmakers",
      # skills: ["Fashion Designing"],
      # has_onboarded: false
    }

    # Merge provided updates with defaults
    final_updates = default_updates.merge(updates)

    if final_updates.empty?
      puts "No updates specified. Exiting..."
      return
    end

    puts "Updates to apply: #{final_updates.inspect}"

    User.find_each(batch_size: 100) do |user|
      update_user(user, final_updates)
    end

    print_summary
  end

  def update_specific_users(user_ids, updates)
    puts "Starting update of specific users..."
    puts "User IDs to process: #{user_ids.join(', ')}"

    if updates.empty?
      puts "No updates specified. Exiting..."
      return
    end

    puts "Updates to apply: #{updates.inspect}"

    user_ids.each do |user_id|
      user = User.find_by(id: user_id)
      if user
        update_user(user, updates)
      else
        @failed_count += 1
        @errors << "User with ID #{user_id} not found"
      end
    end

    print_summary
  end

  def update_users_by_criteria(criteria, updates)
    puts "Starting update of users matching criteria: #{criteria.inspect}"

    users = User.where(criteria)
    puts "Found #{users.count} users matching criteria"

    if updates.empty?
      puts "No updates specified. Exiting..."
      return
    end

    puts "Updates to apply: #{updates.inspect}"

    users.find_each(batch_size: 100) do |user|
      update_user(user, updates)
    end

    print_summary
  end

  private

  def update_user(user, updates)
    begin
      # Validate skills if provided
      if updates.key?(:skills) && updates[:skills].present?
        invalid_skills = updates[:skills] - User::SKILLS_CHOICES
        if invalid_skills.any?
          raise "Invalid skills: #{invalid_skills.join(', ')}"
        end
      end

      # Validate profession if provided
      if updates.key?(:profession) && updates[:profession].present?
        unless User::PROFESSION_CHOICES.include?(updates[:profession])
          raise "Invalid profession: #{updates[:profession]}"
        end
      end

      user.update!(updates)
      @updated_count += 1
      puts "✓ Updated user #{user.id} (#{user.email})"

    rescue StandardError => e
      @failed_count += 1
      error_message = "✗ Failed to update user #{user.id} (#{user.email}): #{e.message}"
      @errors << error_message
      puts error_message
    end
  end

  def print_summary
    puts "\n" + "="*50
    puts "BULK UPDATE SUMMARY"
    puts "="*50
    puts "Successfully updated: #{@updated_count} users"
    puts "Failed updates: #{@failed_count} users"

    if @errors.any?
      puts "\nErrors encountered:"
      @errors.each { |error| puts "  - #{error}" }
    end

    puts "="*50
  end
end

# Example usage scenarios
if __FILE__ == $0
  updater = BulkUserUpdater.new

  # Uncomment and modify one of the following examples:

  # Example 1: Update all users with default profession
  # updater.update_all_users({
  #   profession: "Tailors / Dressmakers",
  #   has_onboarded: false
  # })

  # Example 2: Update specific users by ID
  # user_ids = ["uuid-1", "uuid-2", "uuid-3"]  # Replace with actual UUIDs
  # updater.update_specific_users(user_ids, {
  #   profession: "Fashion Designers",
  #   skills: ["Fashion Designing", "Fashion Illustration"]
  # })

  # Example 3: Update users based on criteria
  # updater.update_users_by_criteria(
  #   { profession: nil },  # Users without profession
  #   { profession: "Tailors / Dressmakers", has_onboarded: false }
  # )

  # Example 4: Set onboarding status for all users
  # updater.update_all_users({ has_onboarded: false })

  # Example 5: Add skills to users who don't have any
  # updater.update_users_by_criteria(
  #   { skills: [nil, []] },  # Users with no skills
  #   { skills: ["Fashion Designing"] }
  # )

  puts "Bulk user update script loaded successfully!"
  puts "Uncomment and modify one of the example scenarios above to run updates."
  puts "Available profession choices: #{User::PROFESSION_CHOICES}"
  puts "Available skills choices: #{User::SKILLS_CHOICES}"
end
