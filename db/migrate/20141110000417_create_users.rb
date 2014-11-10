class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, :null => false
      t.string :password, :null => false
      t.string :token, :null => false

      t.timestamps
    end
    add_index :users, [:username, :password], unique: true
  end
end
