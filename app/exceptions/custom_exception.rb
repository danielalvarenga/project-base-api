# frozen_string_literal: false

class CustomException < StandardError

  attr_reader :error_key, :code, :http_status, :log, :log_level, :log_message, :mdc, :data
  attr_reader :email_alert, :email_subject, :email_message, :emails_from, :email_recommendation

  def initialize(args)
    set_error_key(args)
    args = {} if @error_key == args

    message = args.fetch(:message) { I18n.t("errors.#{@error_key}.message", args) }
    super(message)

    if get_locale_error
      set_attributes(args)
      log_error(args)
      send_mail(args)
    end
  end

  def set_error_key(args)
    return @error_key = args if args.is_a?(Symbol) || args.is_a?(String)
    @error_key = args.fetch(:error_key).try(:downcase) do
      raise(KeyError, 'Error key is not identified in argument')
    end
  end

  def get_locale_error
    i18n_error = I18n.t("errors.#{@error_key}")
    raise(KeyError, 'Error key is not identified in locale') unless i18n_error.respond_to?(:fetch)
    @error = OpenStruct.new(i18n_error)
  end

  def set_attributes(args)
    @mdc = args.fetch(:mdc) if args[:mdc]
    @code = @error.code
    @http_status = @error.http_status if @error.http_status
    @data = @error.data if @error.data
  end

  def log_error(args)
    @log = @error.log
    return unless @log
    @log_level = @error.log_level
    @log_message = args.fetch(:log_message) { I18n.t("errors.#{@error_key}.log_message", args) }

    log_msg = "error_key=#{@error_key}"
    log_msg << "|message=[#{@log_message}]" if @log_message
    log_msg << "|location=[#{backtrace_locations.try(:first)}]" if backtrace_locations.present?
    Rails.logger.send(@log_level, log_msg)
  end

  def send_mail(args)
    @email_alert = @error.email_alert
    return unless @email_alert
    @emails_from = Rails.env.production? ? @error.emails_from : ENV['ACTION_MAILER_DEFAULT_TO']
    @email_subject = args.fetch(:email_subject) { I18n.t("errors.#{@error_key}.email_subject", args) }
    @email_message = args.fetch(:email_message) { I18n.t("errors.#{@error_key}.email_message", args) }
    @email_recommendation = args.fetch(:email_recommendation) { I18n.t("errors.#{@error_key}.email_recommendation", args) }
    Notification::Error.send(self)
  end

end
