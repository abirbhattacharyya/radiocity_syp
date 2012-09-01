class ChangePhoneTypeInProfile < ActiveRecord::Migration
  def up
  	change_column :profiles,:phone,:integer,:limit => 6
  end

  def down
  	change_column :profiles,:phone,:integer
  end
end
