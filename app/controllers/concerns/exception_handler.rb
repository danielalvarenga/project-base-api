# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from CustomException, with: :render_custom_exception
  end

  private

  def unprocessable_entity(e)
    render_error_response(e, :unprocessable_entity)
  end

  def not_found(e)
    render_error_response(e, status: :not_found)
  end

  def render_custom_exception(e)
    render_error_response(e, e.http_status)
  end

  def render_error_response(e, http_status)
    result = { status: 'error',
               error_key: e.error_key || e.class.to_s.split('::').last.underscore,
               message: e.message }
    result[:code] = e.code if e.code
    result[:data] = e.record.errors if e.respond_to?(:record) && e.record&.errors
    result[:data] ||= e.data if e.respond_to?(:data) && e.data

    render json: result, status: http_status || 500
  end
end
