# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Management::AttendanceReportsHelper, type: :helper do
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

  describe Admin::AttendanceReportsHelper, type: :helper do
    describe '#current_sort_key' do
      it "defaults to 'total' when sort is invalid" do
        allow(helper).to receive(:params).and_return(ActionController::Parameters.new(sort: 'weird'))
        expect(helper.current_sort_key).to eq('total')
      end
    end
  end

  describe '#current_sort_dir' do
    it 'defaults to desc when dir is invalid' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(dir: 'sideways'))
      expect(helper.current_sort_dir).to eq('desc')
    end

    it 'defaults to desc when dir missing' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new({}))
      expect(helper.current_sort_dir).to eq('desc')
    end
  end

  describe '#current_sort_title' do
    it 'maps key to human title' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(sort: 'email'))
      expect(helper.current_sort_title).to eq('Email')
    end
  end

  describe '#current_sort_arrow' do
    it 'shows ↑ when asc' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(dir: 'asc'))
      expect(helper.current_sort_arrow).to eq('↑')
    end

    it 'shows ↓ when desc or missing' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(dir: 'desc'))
      expect(helper.current_sort_arrow).to eq('↓')
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new({}))
      expect(helper.current_sort_arrow).to eq('↓')
    end
  end

  describe '#next_dir' do
    it 'returns desc when switching columns' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(sort: 'email', dir: 'asc'))
      expect(helper.next_dir(:name)).to eq('desc')
    end

    it 'toggles asc→desc on same column' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(sort: 'name', dir: 'asc'))
      expect(helper.next_dir(:name)).to eq('desc')
    end

    it 'toggles desc→asc on same column' do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(sort: 'name', dir: 'desc'))
      expect(helper.next_dir(:name)).to eq('asc')
    end
  end

  describe '#sort_link' do
    it "adds 'active' class when sorting same key" do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(sort: 'name', dir: 'desc'))
      html = helper.sort_link('Name', :name)
      expect(html).to include('class="sort-button active"')
    end

    it "omits 'active' when sorting a different key" do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(sort: 'email', dir: 'asc'))
      html = helper.sort_link('Name', :name)
      expect(html).to include('class="sort-button "')
    end
  end
end
