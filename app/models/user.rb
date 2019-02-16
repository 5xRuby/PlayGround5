# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                  :bigint(8)        not null, primary key
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

  def self.from_omniauth(auth)
    where(gitlab_id: auth.uid).first_or_create do |user|
      user.username = auth.info.username
    end
  end
end
