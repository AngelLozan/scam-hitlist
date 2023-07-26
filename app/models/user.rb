# frozen_string_literal: true

class User < ApplicationRecord
  # has_one_attached :image
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2]

  # def self.from_google(email:, uid:)
  #   find_or_create_by!(email: email, uid: uid, provider: "google_oauth2")
  # end

  # def self.from_google(u)
  #   create_with(uid: u[:uid], provider: "google_oauth2",
  #               password: Devise.friendly_token[0, 20]).find_or_create_by!(email: u[:email], image: u[:image])
  # end

  def self.from_google(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      # user.full_name = auth.info.name # assuming the user model has a name
      user.image = auth.info.image
    end
  end
end
