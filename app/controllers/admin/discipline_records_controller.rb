# frozen_string_literal: true

module Admin
  class DisciplineRecordsController < BaseController
    load_and_authorize_resource
    before_action :require_admin!
    layout 'admin'

    def index
      @discipline_records = DisciplineRecord.includes(:user, :given_by).order(created_at: :desc)
    end

    def show; end

    def new
      @discipline_record = DisciplineRecord.new
    end

    def edit; end

    def create
      @discipline_record = DisciplineRecord.new(discipline_record_params)
      @discipline_record.given_by = current_user

      if @discipline_record.save
        redirect_to admin_discipline_records_path, notice: I18n.t('discipline_records.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @discipline_record.update(discipline_record_params)
        redirect_to admin_discipline_record_path(@discipline_record),
                    notice: I18n.t('discipline_records.update')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @discipline_record.destroy!
      redirect_to admin_discipline_records_path, notice: I18n.t('discipline_records.deleted')
    end

    private

    def discipline_record_params
      params.require(:discipline_record).permit(:user_id, :points, :reason)
    end

    def require_admin!
      return if current_user.has_role?(:admin)

      redirect_to root_path, alert: I18n.t('alerts.not_authorized')
    end
  end
end
