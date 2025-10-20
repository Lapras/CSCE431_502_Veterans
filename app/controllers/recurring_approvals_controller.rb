# frozen_string_literal: true

class RecurringApprovalsController < ApplicationController
  layout 'admin'
  before_action :require_admin!
  before_action :set_recurring_excusal, only: [:create]

  def create
    if @recurring_excusal.recurring_approval.present?
      flash[:alert] = I18n.t('recurring_approvals.already_reviewed')
      redirect_to approvals_path and return
    end

    @approval = @recurring_excusal.build_recurring_approval(approval_params)
    @approval.approved_by_user = current_user
    @approval.decision_at = Time.current

    if @approval.save
      flash[:notice] = "Recurring excusal #{@approval.decision}."
    else
      flash[:alert] = "Error processing approval: #{@approval.errors.full_messages.join(', ')}"
    end
    redirect_to approvals_path
  end

  private

  def set_recurring_excusal
    @recurring_excusal = RecurringExcusal.find(params[:recurring_excusal_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] =  I18n.t('recurring_approvals.not_found')
    redirect_to approvals_path
  end

  def approval_params
    params.require(:recurring_approval).permit(:decision, :comment)
  end

  def require_admin!
    return if current_user&.has_role?(:admin)

    redirect_to events_path, alert: I18n.t('alerts.not_admin')
  end
end
