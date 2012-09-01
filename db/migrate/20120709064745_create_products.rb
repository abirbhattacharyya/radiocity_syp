class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :user_id
      t.string :name
      t.text :description
      t.float :regular_price
      t.float :target_price
      t.integer :quantity
      t.integer :product_type
      t.boolean :is_live, :default => true	
      t.timestamps
    end
    add_attachment :products, :image
  end
end
