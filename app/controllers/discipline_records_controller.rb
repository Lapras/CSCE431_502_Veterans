# frozen_string_literal: true

class DisciplineRecordsController < ApplicationController
  layout 'user'
  load_and_authorize_resource
  def index
    # Users only see their own records
    @discipline_records = DisciplineRecord.accessible_by(current_ability)
  end

  def show; end
end
