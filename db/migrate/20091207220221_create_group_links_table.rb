class CreateGroupLinksTable < ActiveRecord::Migration
  def self.up
    create_table :group_links, :id => false do |t|
      t.integer :group_id
      t.integer :link_id
    end
  end

  def self.down
  end
end
