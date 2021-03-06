module TelegramCommon
  module Patches
    module UserPatch
      def self.included(base)
        base.class_eval do
          unloadable

          has_one :telegram_account, dependent: :destroy, class_name: '::TelegramCommon::Account'
        end
      end
    end
  end
end
User.send(:include, TelegramCommon::Patches::UserPatch)
