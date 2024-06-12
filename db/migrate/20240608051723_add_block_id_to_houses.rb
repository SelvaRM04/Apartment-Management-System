class AddBlockIdToHouses < ActiveRecord::Migration[7.1]
  def change
    add_column :houses, :block_id, :integer
  end
end
