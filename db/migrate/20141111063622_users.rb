class Users < ActiveRecord::Migration
  def change
    create_table :users, 'DEFAULT CHARSET' => 'utf8' do |t|
      t.string :name, :limit => 100, :null => false
      t.string :email, :limit => 255, :null => false
      t.column :password, 'CHAR(44) CHARACTER SET ascii', :null => false
      t.column :salt, 'CHAR(8) CHARACTER SET ascii', :null => false
      t.column :passkey, 'CHAR(44) CHARACTER SET ascii', :null => false, :index => true
    end
  end
end
