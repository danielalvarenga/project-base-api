class HomeController < ApplicationController

  def index
    raise ExceptionHandler::ApplicationException.new(error_key: :unknown)
    render json: {status: 'ok'}, status: :ok
  end
end
