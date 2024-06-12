class AddHouseIdToMsg < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :house_id, :integer
  end
end
