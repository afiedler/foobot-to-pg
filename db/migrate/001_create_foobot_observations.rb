class CreateFoobotObservations < ActiveRecord::Migration
  def change
    create_table :foobot_observations, force: true do |t|
      t.string :uuid
      t.timestamp :ts
      t.decimal :all_pollution
      t.decimal :temperature
      t.decimal :humidity
      t.decimal :pm
      t.decimal :co2
      t.decimal :voc
    end

    add_index :foobot_observations, [:uuid, :ts], unique: true
  end
end