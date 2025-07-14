class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets do |t|
      t.integer :user_id, null: false
      t.string :title, null: false
      t.datetime :received_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      
      t.timestamps
    end
    
    add_index :tickets, :user_id
    add_index :tickets, :received_at
  end
end
