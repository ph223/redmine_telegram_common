class RedmineTelegramConnectionsController < ApplicationController
  unloadable

  skip_before_filter :check_if_login_required, :check_password_change

  def create
    @user = User.find(params[:user_id])

    @telegram_account = Telegram::Account.find_by(telegram_id: params[:telegram_id])

    notice = connect_telegram_account_to_user

    redirect_to home_path, notice: notice
  end

  private

  def connect_telegram_account_to_user
    if @user.mail == params[:user_email] && params[:token] == @telegram_account.token
      @telegram_account.user = @user
      @telegram_account.save

      if Redmine::Plugin.installed?('redmine_2fa')
        @user.auth_source = Redmine2FA::AuthSource::Telegram.first
        @user.save
      end
    end

    if @telegram_account.user.present?
      t('redmine_telegram_common.redmine_telegram_connections.create.success')
    else
      t('redmine_telegram_common.redmine_telegram_connections.create.error')
    end
  end
end
