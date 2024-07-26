class AddPasswordDigestToAdmin < ActiveRecord::Migration[7.1]
  def change
    add_column :admins, :password_digest, :string
  end
end
