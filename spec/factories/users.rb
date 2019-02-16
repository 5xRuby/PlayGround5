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

FactoryBot.define do
  factory :user do
  end
end
