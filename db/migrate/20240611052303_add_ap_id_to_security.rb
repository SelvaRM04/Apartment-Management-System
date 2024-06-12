class AddApIdToSecurity < ActiveRecord::Migration[7.1]
  def change
    add_column :securities, :apartment_id, :integer
  end
end
