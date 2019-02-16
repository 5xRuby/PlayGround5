# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                  :bigint(8)        not null, primary key
#  access_token        :string
#  remember_created_at :datetime
#  username            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  gitlab_id           :integer
#
# Indexes
#
#  index_users_on_gitlab_id  (gitlab_id)
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: %i[gitlab]

  def keys
    site = Rails.application.credentials.gitlab[:site]
    uri = URI("#{site}/user/keys?access_token=#{access_token}")
    @keys ||= Oj.load(Net::HTTP.get(uri))&.map { |item| item['key'] }
  end

  def self.from_omniauth(auth)
    result = where(gitlab_id: auth.uid).first_or_create do |user|
      user.username = auth.info.username
    end
    result.update(access_token: auth.dig('credentials', 'token'))
    result
  end
end
