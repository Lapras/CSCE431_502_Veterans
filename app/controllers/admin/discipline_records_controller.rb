module Admin
  class DisciplineRecordsController < ApplicationController
    before_action :set_discipline_record, only: %i[show edit update destroy]
    layout 'admin'

    def index
      @discipline_records = DisciplineRecord.includes(:user, :given_by).order(created_at: :desc)
    end

    def show
    end

    def new
      @discipline_record = DisciplineRecord.new
    end

    def edit
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

    def update
      if @discipline_record.update(discipline_record_params)
        redirect_to admin_discipline_record_path(@discipline_record),
                    notice: 'Discipline record was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @discipline_record.destroy
      redirect_to admin_discipline_records_path, notice: 'Record deleted.'
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_discipline_record
      @discipline_record = DisciplineRecord.find(params[:id])
    end

    def discipline_record_params
      params.require(:discipline_record).permit(:user_id, :points, :reason)
    end

    def require_admin!
      redirect_to root_path, alert: 'Not authorized.' unless current_user.admin?
    end
  end
end
