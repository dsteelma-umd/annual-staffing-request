class HomeController < ApplicationController
  include PersonnelRequestController

  def index
    @requests = @model_klass.where(user: current_user).order(params[:sort])
    respond_to do |format|
      format.html { @requests = @requests.paginate(page: params[:page]) }
      format.xlsx { send_xlsx(@requests, @model_klass) }
    end
  end

  private

    def model_klass
      Request
    end
end
