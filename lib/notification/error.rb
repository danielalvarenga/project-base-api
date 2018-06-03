# frozen_string_literal: true

module Notification
  class Error

    class << self

      def send(exception)
        raise AplicationException.new(error_key: 'email_not_sent') unless exception.try(:error_key)

        return unless exception.email_alert

        # Send email
        begin
          ErrorNotificationMailer.send_notification(
            emails: emails_from,
            subject: "#{environment_abbr[Rails.env.to_sym]}#{subject}",
            message: get_message(exception)
          ).deliver_later
        rescue Exception => e
          raise AplicationException.new(error_key: 'email_not_sent', log_message: "exception=#{e.inspect}")
          Rails.logger.error e
        end
      end

      def environment_abbr
        { test: '[TEST]', staging: '[STG]', production: '', development: '[DEV]' }
      end

      def get_message(exception)
        message = (exception.email_message ? "#{exception.email_message}<br />" : '').to_s
        message << "<br />Recomendation:<br />#{exception.recomendation_message}<br />" if exception.recomendation_message
        message << "<br /><h6>Date of occurence: #{Time.current}<br />"
        message << "Context indentifier (mdc): #{args[:mdc]}" if args[:mdc]
        message << '</h6>'
      end

    end

  end
end
