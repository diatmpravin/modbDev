class CreateLandmarks < ActiveRecord::Migration
  def self.up
    create_table :landmarks do |t|
      t.integer :account_id
      t.column :latitude, :decimal, :precision => 8, :scale => 5
      t.column :longitude, :decimal, :precision => 8, :scale => 5
      t.integer :radius, :default => 100
      t.string :name, :limit => 30
      t.timestamps
    end
  end

  def self.down
    drop_table :landmarks
  end
end
