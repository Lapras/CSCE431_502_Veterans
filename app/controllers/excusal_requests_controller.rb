# frozen_string_literal: true

class ExcusalRequestsController < ApplicationController
  before_action :authenticate_user!

  def new
    @excusal_request = ExcusalRequest.new
    @excusal_request.event_id = params[:event_id] if params[:event_id]
  end

  def create
    @excusal_request = current_user.excusal_requests.build(excusal_request_params)
    if @excusal_request.save
      flash[:notice] = 'Excusal request is sent.'
      redirect_to dashboard_path
    else
      flash.now[:alert] = 'Error: Missing required fields.'
      render :new
    end
  end

  private

  def excusal_request_params
    params.require(:excusal_request).permit(:event_id, :reason)
  end
end
