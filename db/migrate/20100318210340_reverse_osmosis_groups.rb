class ReverseOsmosisGroups < ActiveRecord::Migration
  def self.up
    create_table :device_groups do |t|
      t.integer :account_id
      t.string :name, :limit => 30
      t.boolean :delta, :default => true
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.text :grading
      t.timestamps
    end
  
    drop_table :groups

    create_table :device_group_links do |t|
      t.integer :device_group_id
      t.integer :link_id
      t.string :link_type
    end
    
    drop_table :group_links
    
    drop_table :geofence_device_groups
    
    drop_table :landmark_device_groups
    
    add_column :devices, :group_id, :integer
    remove_column :devices, :user_id
  end

  def self.down
    create_table :groups do |t|
      t.integer :account_id
      t.string :name, :limit => 30
      t.string :of, :limit => 30
      t.boolean :delta, :default => true
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.text :grading
      t.timestamps
    end
    
    drop_table :device_groups
    
    create_table :group_links, :id => false do |t|
      t.integer :group_id
      t.integer :link_id
    end
    
    drop_table :device_group_links
    
    create_table :geofence_device_groups, :id => false do |t|
      t.integer :geofence_id
      t.integer :group_id
    end
    
    create_table :landmark_device_groups, :id => false do |t|
      t.integer :landmark_id
      t.integer :group_id
    end
    
    remove_column :devices, :group_id
    add_column :devices, :user_id, :integer
  end
end
