# frozen_string_literal: true
require 'net/http'

module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from Exception, with: :internal_server_error
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::ParameterMissing, with: :parameter_missing
    rescue_from CustomException, with: :custom_error
    rescue_from Net::ReadTimeout, with: :timeout
  end

  def route_not_found
    raise CustomException, 'route_not_found'
  end

  private

  def unprocessable_entity(e)
    render_error_response(e, :unprocessable_entity)
  end

  def not_found(e)
    render_error_response(e, :not_found)
  end

  def parameter_missing(e)
    error = CustomException.new(error_key: :parameter_missing, exception: e)
    render_error_response(error, error.http_status)
  end

  def internal_server_error(e)
    error = CustomException.new(e)
    render_error_response(error, error.http_status)
  end

  def timeout(e)
    error = CustomException.new(error_key: :timeout, exception: e)
    render_error_response(error, error.http_status)
  end

  def custom_error(e)
    render_error_response(e, e.http_status)
  end

  def render_error_response(e, http_status)
    result = { status: e.error_key || e.class.to_s.split('::').last.underscore,
               message: e.message }
    result[:code] = e.code if e.code
    result[:data] = e.record.errors if e.respond_to?(:record) && e.record&.errors
    result[:data] ||= e.data if e.respond_to?(:data) && e.data

    render json: result, status: http_status || 500
  end
end
