class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.integer :account_id
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :tags
  end
end