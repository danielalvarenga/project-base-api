# frozen_string_literal: true

class ErrorNotificationMailer < ApplicationMailer

  default from: ENV['EMAIL_DEV_ALERT']

  def send_notification(args)
    @emails = args[:emails]
    @subject = args[:subject]
    @message = args[:message]

    mail(to: @emails, subject: @subject)
  end

end
