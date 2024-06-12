class AddTypeToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :type, :string
  end
end
