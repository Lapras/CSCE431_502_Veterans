module Admin
  class BaseController < ApplicationController
    before_action -> { require_role!(:admin, :officer) }

    load_and_authorize_resource

    layout 'admin'
  end
end
