class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.integer :from_id
      t.string :from_desig
      t.integer :to_id
      t.string :to_desig
      t.string :message

      t.timestamps
    end
  end
end
