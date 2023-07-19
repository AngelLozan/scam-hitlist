# frozen_string_literal: true

FactoryBot.define do
  factory :auth_hash, class: OmniAuth::AuthHash do
    initialize_with do
      OmniAuth::AuthHash.new({
                               provider:,
                               uid:,
                               info: {
                                 email:
                               }
                             })
    end

    trait :google do
      provider { 'google_oauth2' }
      sequence(:uid)
      email { ENV.fetch('EMAIL', nil) }
    end
  end
end

#   factory :user do
#     email { ENV['EMAIL'] }
#     provider { "google_oauth2" }
#     password { ENV['PASSWORD'] }
#   end
# end

#   factory :user do
#     initialize_with do
#       OmniAuth::AuthHash.new({
#         provider: provider,
#         uid: uid,
#         info: {
#           email: email,
#         },
#       })
#     end

#     trait :google do
#       provider { "google_oauth2" }
#       uid { :uid }
#       email { ENV["EMAIL"] }
#     end
#   end
# end
