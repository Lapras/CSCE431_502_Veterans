# frozen_string_literal: true

class ExcusalRequestsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new create]

  def new
    @excusal_request = ExcusalRequest.new
    @excusal_request.event_id = params[:event_id] if params[:event_id]
  end

  def create
    collection = current_user.respond_to?(:excusal_requests) ? current_user.excusal_requests : nil
    @excusal_request =
      collection ? collection.build(excusal_request_params) : ExcusalRequest.new(excusal_request_params)

    if @excusal_request.save
      redirect_to events_path, notice: I18n.t('excusal.submit')
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def excusal_request_params
    params.require(:excusal_request).permit(:event_id, :reason)
  end
end
