class AddOwnerIdToHouse < ActiveRecord::Migration[7.1]
  def change
    add_column :houses, :owner_id, :integer 
  end
end
