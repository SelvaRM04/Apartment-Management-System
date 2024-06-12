class AddApartmentIdToBlock < ActiveRecord::Migration[7.1]
  def change
    add_column :blocks, :apartment_id, :integer
  end
end
