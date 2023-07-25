require "rails_helper"
require 'date'
require 'nokogiri'

RSpec.describe IocsController, type: :controller do
  render_views
  before do
    @controller = IocsController.new
  end

  describe "GET /iocs" do
    context "when user is not logged in" do
      it "redirects to login page" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "when user is logged in" do
      it "returns http success" do
        authenticate # See private method

        get :index
        expect(response).to have_http_status(:success)
      end

      it "allows creation of an IOC" do
        ioc = Ioc.create!(url: 'https://www.google.com', report_method_one: 'email', comments: 'test')
        expect(ioc).to be_valid
        expect(ioc.url).to eq('https://www.google.com')
      end

      it "allows user to destroy an IOC" do
        ioc = Ioc.create!(url: 'https://www.google.com', report_method_one: 'email', comments: 'test')

        expect do
          # delete :destroy, params: { id: ioc.id }
          ioc.destroy!
        end.to change(Ioc, :count).by(-1)
      end
    end
  end

  describe 'Edit an Ioc' do
    let(:ioc) { Ioc.create!(url: 'https://www.google.com', report_method_one: 'email', comments: 'test', host: "hm-changed") }

    before do
      authenticate
      get :edit, params: { id: ioc.id }
    end

    it 'succesfully redirects to the edit page' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Reported route' do
    context 'when a user is logged in' do
      before do
        authenticate
        Ioc.create!(url: 'https://www.bing.com', report_method_one: 'email', comments: 'test', status: 1)
        Ioc.create!(url: 'https://www.google.com', report_method_one: 'email', comments: 'test', status: 0)
        get :reported
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "displays only reported IOCs" do
        expect(Ioc.reported.count).to eq 1
      end
    end
  end

  describe '2b_reported route' do
    context 'when a user is logged in' do
      before do
        authenticate
        Ioc.create!(url: 'https://www.bing.com', report_method_one: 'email', comments: 'test', status: 1)
        Ioc.create!(url: 'https://www.google.com', report_method_one: 'email', comments: 'test', status: 0)
        get :tb_reported
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "displays only newly added IOCs" do
        expect(Ioc.tb_reported.count).to eq 1
      end

      it 'displays two table rows, headings and one added IOC' do
        process :tb_reported, method: :get
        # byebug Can check response.body to troubleshoot.
        html = Nokogiri::HTML(response.body)
        expect(html.css('tr').count).to eq 2
      end
    end
  end

  describe 'PG search' do
    before do
      Ioc.create!(url: 'https://www.bing.com', report_method_one: 'email', comments: 'test', status: 1)
    end

    it "should return the correct url" do
      result = Ioc.search_by_url('www.bing.com')
      expect(result.count).to eq 1
    end
  end

  describe 'follow-up route' do
    t = DateTime.now - 14
    puts t

    before do
      authenticate
      Ioc.create!(url: 'https://www.bing.com', report_method_one: 'email', comments: 'test', status: 1,
                  created_at: t)
      get :follow_up
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "should display IOCs that are reported and not followed up on in the last 14 days" do
      expect(Ioc.follow_up_needed.count).to eq 1
    end
  end

  describe 'simple_create route' do
    before do
      authenticate
    end

    it 'routes / to iocs#simple_create' do
      expect(post: '/iocs/simple_create').to route_to(
        controller: "iocs",
        action: 'simple_create'
      )
    end

    # it 'redirects back to the pages#home after successful creation' do
    #   expect(flash[:notice]).to eq('Ioc was successfully created.')
    #   # expect(response).to redirect_to(:root)
    # end
  end

  # Test end
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
