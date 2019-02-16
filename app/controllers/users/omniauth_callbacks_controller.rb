# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def gitlab
      @user = User.from_omniauth(request.env['omniauth.auth'])

      return accept_signin if @user.persisted?

      # TODO: Display 401 Page
    end

    private

    def accept_signin
      sign_in_and_redirect @user, event: :authentication
    end
  end
end
