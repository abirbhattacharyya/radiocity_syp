class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :offer_id
      t.integer :quantity
      t.string :transaction_id
      t.string :email
      t.float :price
      t.string :first_name
      t.string :last_name
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :country
      t.string :postal_code	
      t.integer :phone,:limit => 6
      t.integer :cc_number, :limit => 6
  	  t.string :cc_type
  	  t.integer :cc_expiry_m, :limit => 2
  	  t.integer :cc_expiry_y, :limit => 2
      t.timestamps
    end
  end
end
