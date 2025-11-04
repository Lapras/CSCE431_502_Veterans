class DisciplineRecordsController < ApplicationController
  def index
    # Users only see their own records
    @discipline_records = current_user.discipline_records.includes(:given_by)
  end

  def show
    @discipline_record = current_user.discipline_records.find(params[:id])
  end
end
