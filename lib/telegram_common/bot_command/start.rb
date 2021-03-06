module TelegramCommon
  module BotCommand
    module Start
      def start
        update_account

        update_2fa if Redmine::Plugin.installed?('redmine_2fa')

        message = if account.user.present?
                    I18n.t('telegram_common.bot.start.hello')
                  else
                    I18n.t('telegram_common.bot.start.instruction_html')
                  end

        send_message(message)
      end

      private

      def update_account
        account.assign_attributes username: user.username,
                                  first_name: user.first_name,
                                  last_name: user.last_name,
                                  active: true

        write_log_about_new_user if logger && account.new_record?

        account.save!
      end

      def update_2fa
        return unless account.user.present? && account.user.two_fa.nil?
        account.user.update two_fa_id: ::Redmine2FA::AuthSource::Telegram.first&.id
      end

      def write_log_about_new_user
        logger.info "New telegram_user #{user.first_name} #{user.last_name} @#{user.username} added!"
      end
    end
  end
end
