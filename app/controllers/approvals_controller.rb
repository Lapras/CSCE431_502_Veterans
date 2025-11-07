# frozen_string_literal: true

class ApprovalsController < ApplicationController
  layout 'admin'
  before_action -> { require_role!(:admin, :officer) }
  before_action :set_excusal_request, only: [:create]

  def index
    @pending_requests   = pending_excusals
    @approved_requests  = approved_excusals
    @denied_requests    = denied_excusals

    @pending_recurring  = pending_recurring_excusals
    @approved_recurring = approved_recurring_excusals
    @denied_recurring   = denied_recurring_excusals
  end

  def create
    return already_reviewed if @excusal_request.approval.present?

    @approval = build_approval(@excusal_request)

    if @approval.save
      flash[:notice] = approval_success_message
    else
      flash[:alert]  = approval_error_message(@approval)
    end

    redirect_to approvals_path
  end

  private

  def pending_excusals
    ExcusalRequest.pending.includes(:user, :event).order(created_at: :desc)
  end

  def approved_excusals
    ExcusalRequest.approved.includes(:user, :event, :approval)
                  .order(updated_at: :desc).limit(20)
  end

  def denied_excusals
    ExcusalRequest.denied.includes(:user, :event, :approval)
                  .order(updated_at: :desc).limit(20)
  end

  def pending_recurring_excusals
    RecurringExcusal.pending.includes(:user).order(created_at: :desc)
  end

  def approved_recurring_excusals
    RecurringExcusal.approved.includes(:user, :recurring_approval)
                    .order(updated_at: :desc).limit(20)
  end

  def denied_recurring_excusals
    RecurringExcusal.denied.includes(:user, :recurring_approval)
                    .order(updated_at: :desc).limit(20)
  end

  def already_reviewed
    flash[:alert] = I18n.t('approvals.already_reviewed')
    redirect_to approvals_path
  end

  def build_approval(excusal_request)
    approval = excusal_request.build_approval(approval_params)
    approval.approved_by_user = current_user
    approval.decision_at = Time.current
    approval
  end

  def approval_success_message
    "Excusal request #{@approval.decision}."
  end

  def approval_error_message(approval)
    "Error processing approval: #{approval.errors.full_messages.join(', ')}"
  end

  def set_excusal_request
    @excusal_request = ExcusalRequest.find(params[:excusal_request_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = I18n.t('approvals.not_found')
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
