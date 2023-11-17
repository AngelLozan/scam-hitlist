# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    
    def google_oauth2
      # user = User.from_google(from_google_params)
      user = User.from_google(auth)

      if user.present? && valid(user)
        sign_out_all_scopes
        flash[:notice] = t 'devise.omniauth_callbacks.success', kind: 'Google'
        sign_in_and_redirect user, event: :authentication
      else
        flash[:alert] =
          t 'devise.omniauth_callbacks.failure', kind: 'Google', reason: "#{auth.info.email} is not authorized."
        redirect_to new_user_session_path
      end
    end

    private

    def auth
      @auth ||= request.env['omniauth.auth']
    end

    def valid(user)
      user.email == 'dean@exodus.io' || 'scott.lo@exodus.io'
    end
  end
end
