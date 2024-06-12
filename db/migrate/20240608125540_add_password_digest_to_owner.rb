class AddPasswordDigestToOwner < ActiveRecord::Migration[7.1]
  def change
    add_column :owners, :passowrd_digest, :string
  end
end
