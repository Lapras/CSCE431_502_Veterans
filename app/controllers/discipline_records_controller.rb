class DisciplineRecordsController < ApplicationController
  layout 'user'
  def index
    # Users only see their own records
    @discipline_records = current_user.discipline_records
  end

  def show
    @discipline_record = current_user.discipline_records.find(params[:id])
  end
end
