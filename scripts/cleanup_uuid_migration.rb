#!/usr/bin/env ruby
# Script to clean up any database inconsistencies after UUID migration
# Usage: ruby scripts/cleanup_uuid_migration.rb

require_relative '../config/environment'

class UuidMigrationCleanup
  def self.run
    puts "Starting UUID migration cleanup..."

    # Check for any auth_codes with null user_id
    cleanup_auth_codes

    # Check for any clients with null user_id
    cleanup_clients

    # Check for any custom_fields with null user_id
    cleanup_custom_fields

    # Check for any tokens with null user_id
    cleanup_tokens

    # Verify all foreign key relationships
    verify_relationships

    puts "Cleanup completed!"
  end

  private

  def self.cleanup_auth_codes
    puts "\nChecking auth_codes table..."

    null_count = AuthCode.where(user_id: nil).count
    puts "Auth codes with null user_id: #{null_count}"

    if null_count > 0
      puts "Deleting orphaned auth codes..."
      AuthCode.where(user_id: nil).delete_all
      puts "✓ Deleted #{null_count} orphaned auth codes"
    end

    # Check for auth codes pointing to non-existent users
    orphaned = AuthCode.left_joins(:user).where(users: { id: nil })
    orphaned_count = orphaned.count

    if orphaned_count > 0
      puts "Found #{orphaned_count} auth codes pointing to non-existent users"
      orphaned.delete_all
      puts "✓ Deleted orphaned auth codes"
    end
  end

  def self.cleanup_clients
    puts "\nChecking clients table..."

    null_count = Client.where(user_id: nil).count
    puts "Clients with null user_id: #{null_count}"

    if null_count > 0
      puts "WARNING: Found clients with null user_id"
      puts "These should be assigned to a user manually or deleted"

      # Option to assign to first user or delete
      first_user = User.first
      if first_user
        puts "Assigning orphaned clients to user: #{first_user.email}"
        Client.where(user_id: nil).update_all(user_id: first_user.id)
        puts "✓ Assigned #{null_count} clients to #{first_user.email}"
      else
        puts "No users found, deleting orphaned clients..."
        Client.where(user_id: nil).delete_all
        puts "✓ Deleted orphaned clients"
      end
    end

    # Check for clients pointing to non-existent users
    orphaned = Client.left_joins(:user).where(users: { id: nil })
    orphaned_count = orphaned.count

    if orphaned_count > 0
      puts "Found #{orphaned_count} clients pointing to non-existent users"
      first_user = User.first
      if first_user
        orphaned.update_all(user_id: first_user.id)
        puts "✓ Reassigned orphaned clients to #{first_user.email}"
      else
        orphaned.delete_all
        puts "✓ Deleted orphaned clients"
      end
    end
  end

  def self.cleanup_custom_fields
    puts "\nChecking custom_fields table..."

    null_count = CustomField.where(user_id: nil).count
    puts "Custom fields with null user_id: #{null_count}"

    if null_count > 0
      first_user = User.first
      if first_user
        puts "Assigning orphaned custom fields to user: #{first_user.email}"
        CustomField.where(user_id: nil).update_all(user_id: first_user.id)
        puts "✓ Assigned #{null_count} custom fields to #{first_user.email}"
      else
        puts "No users found, deleting orphaned custom fields..."
        CustomField.where(user_id: nil).delete_all
        puts "✓ Deleted orphaned custom fields"
      end
    end

    # Check for custom fields pointing to non-existent users
    orphaned = CustomField.left_joins(:user).where(users: { id: nil })
    orphaned_count = orphaned.count

    if orphaned_count > 0
      puts "Found #{orphaned_count} custom fields pointing to non-existent users"
      first_user = User.first
      if first_user
        orphaned.update_all(user_id: first_user.id)
        puts "✓ Reassigned orphaned custom fields to #{first_user.email}"
      else
        orphaned.delete_all
        puts "✓ Deleted orphaned custom fields"
      end
    end
  end

  def self.cleanup_tokens
    puts "\nChecking tokens table..."

    null_count = Token.where(user_id: nil).count
    puts "Tokens with null user_id: #{null_count}"

    if null_count > 0
      puts "Deleting orphaned tokens..."
      Token.where(user_id: nil).delete_all
      puts "✓ Deleted #{null_count} orphaned tokens"
    end

    # Check for tokens pointing to non-existent users
    orphaned = Token.left_joins(:user).where(users: { id: nil })
    orphaned_count = orphaned.count

    if orphaned_count > 0
      puts "Found #{orphaned_count} tokens pointing to non-existent users"
      orphaned.delete_all
      puts "✓ Deleted orphaned tokens"
    end
  end

  def self.verify_relationships
    puts "\nVerifying all relationships..."

    # Test creating associations
    user = User.first
    if user
      puts "Testing user associations for: #{user.email}"

      # Test auth code creation
      begin
        auth_code = user.generate_auth_code!
        puts "✓ Auth code creation works: #{auth_code.user_id}"
      rescue => e
        puts "✗ Auth code creation failed: #{e.message}"
      end

      # Test client creation
      begin
        client = user.clients.create!(
          name: "Test Client",
          gender: "Male",
          measurement_unit: "inches"
        )
        puts "✓ Client creation works: #{client.user_id}"
        client.destroy # Clean up
      rescue => e
        puts "✗ Client creation failed: #{e.message}"
      end

      # Test custom field creation
      begin
        custom_field = user.custom_fields.create!(
          field_name: "Test Field"
        )
        puts "✓ Custom field creation works: #{custom_field.user_id}"
        custom_field.destroy # Clean up
      rescue => e
        puts "✗ Custom field creation failed: #{e.message}"
      end
    end

    puts "\nDatabase statistics:"
    puts "Users: #{User.count}"
    puts "Auth codes: #{AuthCode.count}"
    puts "Clients: #{Client.count}"
    puts "Custom fields: #{CustomField.count}"
    puts "Tokens: #{Token.count}"
  end
end

if __FILE__ == $0
  UuidMigrationCleanup.run
end
