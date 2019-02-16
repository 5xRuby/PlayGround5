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

require 'rails_helper'

RSpec.describe User, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
