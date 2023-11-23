require "rails_helper"

RSpec.describe HealthController, type: :controller do
  before do
    @controller = HealthController.new
  end

  describe "GET /health/live" do
    context "when checking the server liveness" do
      it "will return OK and status 200 if live" do
        get :liveness
        expect(response).to have_http_status(200)
        expect(response.body).to eq("OK")
      end
    end
  end

  describe "GET /health/ready" do
    context "when checking the server readiness" do
      it "will return OK and status 200 if database and connections ready" do
        get :readiness
        expect(response).to have_http_status(200)
        expect(response.body).to eq("OK")
      end
    end
  end
end

