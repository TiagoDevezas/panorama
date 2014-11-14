class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # After filter to respond with JSONP when there's a callback
  after_action do |controller| 
    if controller.params[:callback] && controller.params[:format].to_s == 'json'
      controller.response['Content-Type'] = 'application/javascript'
      controller.response.body = "%s(%s)" % [controller.params[:callback], controller.response.body]
    end
  end
end
