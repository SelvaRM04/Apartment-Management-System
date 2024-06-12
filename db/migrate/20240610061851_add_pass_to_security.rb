class AddPassToSecurity < ActiveRecord::Migration[7.1]
  def change
    add_column :securities, :password_digest, :string
  end
end
