require "rails_helper"

RSpec.describe FormsController, type: :controller do
  before do
    @controller = FormsController.new
  end

  describe "GET /forms" do
    context "when user is logged in" do
      it "Forms route is created and can display all forms" do
        authenticate
        get :index
        expect(response).to have_http_status(200)
      end
    end
  end
end

private

def authenticate
  # Stub the OmniAuth behavior
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new(
    provider: "google",
    uid: "123456789",
    info: {
      email: "test@example.com",
      name: "John Doe",
      image: "https://example.com/avatar.jpg"
    }
  )

  allow(controller).to receive(:authenticate_user!) # Stub Devise's authenticate_user! method
  allow(controller).to receive(:current_user) { nil } # Mock current_user method to return nil

  request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:google] # Set the OmniAuth mock auth hash in the request environment
end
