class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer :user_id
      t.string :name
      t.text :address
      t.integer :phone
      t.string :email
      t.string :twitter
      t.string :facebook_url
      t.string :website
      t.string :header_color	
      t.timestamps
    end
    add_attachment :profiles, :logo
  end
end
