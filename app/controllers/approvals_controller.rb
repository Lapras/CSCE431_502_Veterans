class ApprovalsController < ApplicationController
  layout 'admin'
  before_action :require_admin!
  before_action :set_excusal_request, only: [:create]
  
  def index
    @pending_requests = ExcusalRequest.pending.includes(:user, :event).order(created_at: :desc)
    @approved_requests = ExcusalRequest.approved.includes(:user, :event, :approval).order(updated_at: :desc).limit(20)
    @denied_requests = ExcusalRequest.denied.includes(:user, :event, :approval).order(updated_at: :desc).limit(20)
  end
  
  def create
    if @excusal_request.approval.present?
      flash[:alert] = "This request has already been reviewed."
      redirect_to approvals_path and return
    end
    
    @approval = @excusal_request.build_approval(approval_params)
    @approval.approved_by_user = current_user
    @approval.decision_at = Time.current
    
    if @approval.save
      flash[:notice] = "Excusal request #{@approval.decision}."
      redirect_to approvals_path
    else
      flash[:alert] = "Error processing approval: #{@approval.errors.full_messages.join(', ')}"
      redirect_to approvals_path
    end
  end
  
  private
  
  def set_excusal_request
    @excusal_request = ExcusalRequest.find(params[:excusal_request_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Excusal request not found."
    redirect_to approvals_path
  end
  
  def approval_params
    params.require(:approval).permit(:decision, :comment)
  end

  def require_admin!
    return if current_user&.has_role?(:admin)

    redirect_to events_path, alert: I18n.t('alerts.not_admin')
  end
end