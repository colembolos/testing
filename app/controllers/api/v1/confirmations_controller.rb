module Api
  module V1
    class ConfirmationsController < DeviseTokenAuth::ConfirmationsController
      protect_from_forgery with: :exception, unless: :json_request?
      include Api::Concerns::ActAsApiRequest
      skip_before_action :check_json_request, on: :show

      # override
      def show
        @resource = resource_class.confirm_by_token(resource_params[:confirmation_token])

        return redirect_to(ENV.fetch('FRONTEND_LOGIN_URL')) unless @resource.errors.empty?

        token = @resource.create_token
        @resource.save!
        redirect_after_confirmation(token)
      end

      private

      def redirect_after_confirmation(token)
        redirect_headers = build_redirect_headers(token.token, token.client)
        redirect_to_url = @resource.build_auth_url(
          ENV.fetch('FRONTEND_CONFIRM_SUCCESS_URL'), redirect_headers
        )

        redirect_to(redirect_to_url)
      end
    end
  end
end
