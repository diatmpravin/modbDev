class CreatePoints < ActiveRecord::Migration
  def self.up
    create_table :points do |t|
      t.integer :event
      t.datetime :occurred_at
      t.decimal :latitude, :precision => 8, :scale => 5
      t.decimal :longitude, :precision => 8, :scale => 5
      t.integer :altitude
      t.integer :speed
      t.boolean :accelerating
      t.boolean :decelerating
      t.integer :rpm
      t.integer :heading
      t.integer :satellites
      t.decimal :hdop, :precision => 4, :scale => 2
      t.integer :miles
      t.timestamps
    end
  end

  def self.down
    drop_table :points
  end
end
