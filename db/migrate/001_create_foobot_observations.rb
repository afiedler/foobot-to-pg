class CreateFoobotObservations < ActiveRecord::Migration
  def change
    create_table :foobot_observations, force: true do |t|
      t.string :uuid
      t.timestamp :ts
      t.decimal :all_pollution
      t.decimal :gas_pollution
      t.decimal :temperature
      t.decimal :humidity
      t.decimal :pm
      t.decimal :pm100
      t.decimal :voc100
    end
  end
end