class ExcusalRequestsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new create]

  def new
    @excusal_request = ExcusalRequest.new
    @excusal_request.event_id = params[:event_id] if params[:event_id]
  end

  def create
    if request.get?
      @excusal_request = ExcusalRequest.new
      return render :create
    end

    collection = current_user&.respond_to?(:excusal_requests) ? current_user.excusal_requests : nil
    @excusal_request = collection ? collection.build(excusal_request_params) : ExcusalRequest.new(excusal_request_params)

    if @excusal_request.save
      render :create
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def excusal_request_params
    params.require(:excusal_request).permit(:event_id, :reason)
  end
end
