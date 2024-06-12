class CreateSecurities < ActiveRecord::Migration[7.1]
  def change
    create_table :securities do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
