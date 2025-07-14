class DebugController < ApplicationController
  def tickets
    @tickets = Ticket.all.order(created_at: :desc)
    render json: @tickets
  end
  
  def tags
    @tags = Tag.all.order(count: :desc)
    render json: @tags
  end
end
