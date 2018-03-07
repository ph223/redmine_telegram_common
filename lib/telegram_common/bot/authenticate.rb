module TelegramCommon
  class Bot::Authenticate
    AUTH_TIMEOUT = 60.minutes

    def self.call(user, auth_data)
      new(user, auth_data).call
    end

    def initialize(user, auth_data)
      @user, @auth_data = user, Hash[auth_data.sort_by { |k, _| k }]
    end

    def call
      return false unless @user.logged? && hash_valid? && up_to_date?

      telegram_account = TelegramCommon::Account.find_or_initialize_by(telegram_id: @auth_data['id'])

      if telegram_account.user_id
        return false unless @user.id == telegram_account.user_id
      else
        telegram_account.user_id = @user.id
      end

      telegram_account.assign_attributes(
        telegram_id: @auth_data['id'],
        **@auth_data.slice(%w[first_name last_name username])
      )
      telegram_account.save
    end

    private

    def hash_valid?
      check_string = @auth_data.except('hash').map { |k, v| "#{k}=#{v}" }.join("\n")
      secret_key = Digest::SHA256.digest(TelegramCommon.bot_token)
      hash = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret_key, check_string)
      hash == @auth_data['hash']
    end

    def up_to_date?
      Time.at(@auth_data['auth_date'].to_i) > Time.now - AUTH_TIMEOUT
    end
  end
end