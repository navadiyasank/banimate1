class CreatePopupSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :popup_settings do |t|
      t.integer :position, default: 1
      t.boolean :status
      t.references :shop, foreign_key: true
      t.float :cart_amount

      t.timestamps
    end
  end
end
