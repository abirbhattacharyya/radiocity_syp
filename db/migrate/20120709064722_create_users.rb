class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password
      t.string :remember_token
      t.date :remember_token_expires_at	
      t.timestamps
    end
  end
end
