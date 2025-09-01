class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients, id: :uuid do |t|
      # Mandatory fields
      t.string :name, null: false
      t.string :gender, null: false
      t.string :measurement_unit, null: false
      t.boolean :in_trash, default: false
      
      # Optional fields
      t.string :phone_number
      t.string :email
      
      # Standard measurements (all stored in centimeters)
      t.decimal :ankle, precision: 8, scale: 2
      t.decimal :bicep, precision: 8, scale: 2
      t.decimal :bottom, precision: 8, scale: 2
      t.decimal :chest, precision: 8, scale: 2
      t.decimal :head, precision: 8, scale: 2
      t.decimal :height, precision: 8, scale: 2
      t.decimal :hip, precision: 8, scale: 2
      t.decimal :inseam, precision: 8, scale: 2
      t.decimal :knee, precision: 8, scale: 2
      t.decimal :neck, precision: 8, scale: 2
      t.decimal :outseam, precision: 8, scale: 2
      t.decimal :shorts, precision: 8, scale: 2
      t.decimal :shoulder, precision: 8, scale: 2
      t.decimal :sleeve, precision: 8, scale: 2
      t.decimal :short_sleeve, precision: 8, scale: 2
      t.decimal :thigh, precision: 8, scale: 2
      t.decimal :top_length, precision: 8, scale: 2
      t.decimal :waist, precision: 8, scale: 2
      t.decimal :wrist, precision: 8, scale: 2

      t.timestamps
    end
    
    add_index :clients, :name
    add_index :clients, :gender
    add_index :clients, :in_trash
    add_index :clients, :email, unique: true, where: "email IS NOT NULL"
  end
end
