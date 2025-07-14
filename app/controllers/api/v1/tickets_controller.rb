class Api::V1::TicketsController < ApplicationController
  # Skip CSRF verification for API endpoints
  skip_before_action :verify_authenticity_token
  def create
    # Validate the request payload
    validation_errors = validate_payload(params)
    
    if validation_errors.any?
      render json: { errors: validation_errors }, status: :unprocessable_entity
      return
    end
    
    begin
      # Create the ticket
      ticket = Ticket.create!(
        user_id: params[:user_id],
        title: params[:title]
      )
      
      # Process tags if present
      if params[:tags].present?
        params[:tags].each do |tag_name|
          Tag.increment_count(tag_name)
        end
      end
      
      # Send webhook with highest count tag
      send_webhook_async
      
      render json: { 
        message: 'Ticket created successfully',
        ticket_id: ticket.id 
      }, status: :created
      
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    rescue => e
      render json: { errors: ['An unexpected error occurred'] }, status: :internal_server_error
    end
  end
  
  private
  
  def validate_payload(params)
    errors = []
    
    # Check required fields
    errors << 'user_id is required' if params[:user_id].blank?
    errors << 'title is required' if params[:title].blank?
    
    # Validate user_id is numeric
    if params[:user_id].present? && !params[:user_id].to_s.match?(/\A\d+\z/)
      errors << 'user_id must be a number'
    end
    
    # Validate tags
    if params[:tags].present?
      unless params[:tags].is_a?(Array)
        errors << 'tags must be an array'
      else
        if params[:tags].length >= 5
          errors << 'tags must be fewer than 5'
        end
      end
    end
    
    errors
  end
  
  def send_webhook_async
    # In a real application, this would be done in a background job
    # For this challenge, I'll do it synchronously
    highest_tag = Tag.highest_count_tag
    
    if highest_tag
      webhook_url = ENV['WEBHOOK_URL'] || 'https://webhook.site/unique-id'
      
      begin
        HTTParty.post(webhook_url, {
          body: {
            tag: highest_tag.name,
            count: highest_tag.count,
            timestamp: Time.current.iso8601
          }.to_json,
          headers: {
            'Content-Type' => 'application/json'
          },
          timeout: 5
        })
      rescue => e
        # Log the error but don't fail the request
        Rails.logger.error "Webhook failed: #{e.message}"
      end
    end
  end
end
