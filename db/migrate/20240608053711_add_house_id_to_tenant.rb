class AddHouseIdToTenant < ActiveRecord::Migration[7.1]
  def change
    add_column :tenants, :house_id, :integer
  end
end
