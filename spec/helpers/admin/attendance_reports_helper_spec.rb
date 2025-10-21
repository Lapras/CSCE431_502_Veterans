# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AttendanceReportsHelper, type: :helper do
  describe '#sort_link' do
    context 'when no current sort is set' do
      it 'generates a link with desc direction' do
        allow(helper).to receive(:params).and_return({ q: 'test' })
        link = helper.sort_link('Name', :name)

        expect(link).to include('/admin/attendance_reports')
        expect(link).to include('sort=name')
        expect(link).to include('dir=desc')
        expect(link).to include('Name')
      end
    end

    context 'when current sort matches the key with desc direction' do
      it 'toggles to asc direction' do
        allow(helper).to receive(:params).and_return({ sort: 'name', dir: 'desc', q: 'search' })
        link = helper.sort_link('Name', :name)

        expect(link).to include('dir=asc')
      end
    end

    context 'when current sort matches the key with asc direction' do
      it 'keeps desc direction' do
        allow(helper).to receive(:params).and_return({ sort: 'name', dir: 'asc', q: '' })
        link = helper.sort_link('Name', :name)

        expect(link).to include('dir=desc')
      end
    end

    context 'when current sort is different from the key' do
      it 'sets desc direction' do
        allow(helper).to receive(:params).and_return({ sort: 'email', dir: 'asc', q: 'test' })
        link = helper.sort_link('Name', :name)

        expect(link).to include('sort=name')
        expect(link).to include('dir=desc')
      end
    end

    context 'when q parameter is present' do
      it 'preserves the search query in the link' do
        allow(helper).to receive(:params).and_return({ sort: 'name', dir: 'asc', q: 'john' })
        link = helper.sort_link('Name', :name)

        expect(link).to include('q=john')
      end
    end
  end
end
