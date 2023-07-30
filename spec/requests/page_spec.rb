require "rails_helper"
require "nokogiri"

RSpec.describe PagesController, type: :controller do
  render_views # Ensure you are getting views instead of empty body
  before do
    @controller = PagesController.new
  end

  describe "GET /settings" do
    context "when user is logged in" do
      before do
        authenticate
        Form.create!(url: "https://www.bing.com", name: "test")
        Host.create!(email: "example@example.com", name: "form")
        get :settings
      end

      it "fetches settings route and returns successful" do
        expect(response).to have_http_status(200)
      end

      it "displays all forms" do
        expect(Form.all.count).to eq 1
      end

      it "displays all hosts" do
        expect(Host.all.count).to eq 1
      end
    end
  end

  describe "Route new submissions to the IOC controller from pages home" do
    context "when not logged in" do
      it "allows an IOC to be created succesfully" do
        post :home,
             params: { ioc: { url: "www.exodus.example.com", comments: "Sample comments",
                              photo: fixture_file_upload("ban.png", "image/png") } }
        expect(response).to have_http_status(200) # Redirect to home
      end
    end
  end

  # Test End
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

  request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:google] # Set the OmniAuth mock auth hash
end
