require 'rails_helper'

RSpec.describe Admin::AttendanceReportsHelper, type: :helper do
  describe '#sort_link' do
    it 'generates a sort link with correct parameters' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(q: 'test', sort: 'name', dir: 'asc'))
      link = helper.sort_link('Name', 'name')
      expect(link).to include('Name')
      expect(link).to include('admin/attendance_reports')
    end

    it 'toggles direction from desc to asc' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(sort: 'name', dir: 'desc'))
      link = helper.sort_link('Name', 'name')
      expect(link).to include('dir=asc')
    end

    it 'defaults to desc for different column' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(sort: 'email', dir: 'asc'))
      link = helper.sort_link('Name', 'name')
      expect(link).to include('dir=desc')
    end

    it 'preserves query parameter' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(q: 'search_term', sort: 'name', dir: 'asc'))
      link = helper.sort_link('Name', 'name')
      expect(link).to include('q=search_term')
    end
  end
end
