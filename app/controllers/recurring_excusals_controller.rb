# frozen_string_literal: true

class RecurringExcusalsController < ApplicationController
  before_action :authenticate_user!

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
      redirect_to recurring_excusals_path, notice: I18n.t('excusal.recurring_submit')
    else
      render :new
    end
  end

  private

  def recurring_excusal_params
    params.require(:recurring_excusal).permit(:reason, :recurring_start_time, :recurring_end_time, recurring_days: [])
  end
end
