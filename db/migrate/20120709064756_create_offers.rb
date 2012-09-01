class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.string :ip
      t.string :response
      t.integer :product_id
      t.float :price
      t.integer :counter
      t.string :token	 
      t.timestamps
    end
  end
end
