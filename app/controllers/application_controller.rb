class ApplicationController < ActionController::Base
  # Only verify CSRF token for non-API requests
  protect_from_forgery with: :null_session
end
