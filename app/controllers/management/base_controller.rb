module Management
  class BaseController < ApplicationController
    before_action -> { require_role!(:admin, :officer) }

    before_action :authenticate_user!
    load_and_authorize_resource

    layout 'admin'

    rescue_from CanCan::AccessDenied do |exception|
      redirect_to root_path, alert: "Access denied: #{exception.message}"
    end
  end
end
