module Admin
  class DisciplineRecordsController < ApplicationController
    layout 'admin'

    def index
      @discipline_records = DisciplineRecord.includes(:user, :given_by).order(created_at: :desc)
    end

    def show
      @discipline_record = DisciplineRecord.find(params[:id])
    end

    def new
      @discipline_record = DisciplineRecord.new
    end

    def create
      @discipline_record = DisciplineRecord.new(discipline_record_params)
      @discipline_record.given_by = current_user

      if @discipline_record.save
        redirect_to admin_discipline_records_path, notice: 'Discipline record created successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      @discipline_record = DisciplineRecord.find(params[:id])
      @discipline_record.destroy
      redirect_to admin_discipline_records_path, notice: 'Record deleted.'
    end

    private

    def discipline_record_params
      params.require(:discipline_record).permit(:user_id, :points, :reason)
    end

    def require_admin!
      redirect_to root_path, alert: 'Not authorized.' unless current_user.admin?
    end
  end
end
