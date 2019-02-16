# frozen_string_literal: true

class AddGitlabToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users, bulk: true do |t|
      t.integer :gitlab_id
      t.string :username
      t.string :access_token
      t.index :gitlab_id
    end
  end
end
