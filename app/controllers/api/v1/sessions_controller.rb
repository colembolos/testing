module Api
  module V1
    class SessionsController < DeviseTokenAuth::SessionsController
      protect_from_forgery with: :null_session
      include Api::Concerns::ActAsApiRequest

      private

      def resource_params
        params.require(:user).permit(:email, :password)
      end

      def render_create_success
        render :create
      end

      def render_create_error_account_locked
        render_error(
          401,
          I18n.t(
            'devise.mailer.unlock_instructions.account_lock_msg',
            time: @resource.decorate.minutes_to_unlock
          )
        )
      end
    end
  end
end
