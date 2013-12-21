class AddUpdatesToConcertoHardwarePlayers < ActiveRecord::Migration
  def change
    remove_column :concerto_hardware_players, :secret
    add_column :concerto_hardware_players, :screen_on_off, :string
  end
end
