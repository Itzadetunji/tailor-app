class EmailService
  def self.send_magic_link(user, auth_code, base_url = "http://localhost:3000")
    magic_link = auth_code.magic_link(base_url)

    # For development, we'll just log the email content
    # In production, you'd integrate with a service like SendGrid, Mailgun, etc.

    # Fallback greeting when first/last name may be blank
    display_name = if user.first_name.present? || user.last_name.present?
      user.full_name.strip
    else
      user.email
    end

    email_body = <<~EMAIL
      Hi #{display_name},

      You can sign in to your account using either:

      1. This 6-digit code: #{auth_code.code}
      2. Or click this magic link: #{magic_link}

      This code will expire in 30 minutes.

      If you didn't request this, please ignore this email.

      Best regards,
      The Tailor App Team
    EMAIL

    Rails.logger.info "=== EMAIL SENT ==="
    Rails.logger.info "To: #{user.email}"
    Rails.logger.info "Subject: Your magic link to sign in"
    Rails.logger.info email_body
    Rails.logger.info "=================="

    # Return success for now
    {
      success: true,
      message: "Magic link sent successfully",
      magic_link: magic_link,
      code: auth_code.code
    }
  end
end
