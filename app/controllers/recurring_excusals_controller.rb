# frozen_string_literal: true

class RecurringExcusalsController < ApplicationController
  layout :determine_layout
  before_action :authenticate_user!
  before_action :set_recurring_excusal, only: %i[approve deny]
  before_action :authorize_admin!, only: %i[approve deny]

  def index
    @recurring_excusals = current_user.recurring_excusals.order(created_at: :desc)
  end

  def new
    @recurring_excusal = current_user.recurring_excusals.new
  end

  def create
    @recurring_excusal = current_user.recurring_excusals.new(recurring_excusal_params)
    @recurring_excusal.status = 'pending'

    if @recurring_excusal.save
      redirect_to recurring_excusals_path, notice: I18n.t('recurring_excusals.request_sent')
    else
      render :new
    end
  end

  def approve
    @recurring_excusal.update!(status: 'approved')
    redirect_to recurring_excusals_path, notice: t('recurring_excusals.approved')
  end

  def deny
    @recurring_excusal.update!(status: 'denied')
    redirect_to recurring_excusals_path, notice: t('recurring_excusals.denied')
  end

  private

  def set_recurring_excusal
    @recurring_excusal = RecurringExcusal.find(params[:id])
  end

  def authorize_admin!
    return if current_user.has_role?(:admin)

    redirect_to recurring_excusals_path, alert: t('alerts.not_authorized')
  end

  def recurring_excusal_params
    params.require(:recurring_excusal).permit(:reason, :evidence_link, :recurring_start_time, :recurring_end_time,
                                              recurring_days: [])
  end

  def determine_layout
    current_user&.has_role?(:admin) ? 'admin' : 'user'
  end
end
