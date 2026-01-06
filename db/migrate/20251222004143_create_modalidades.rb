class CreateModalidades < ActiveRecord::Migration[8.1]
  def change
    create_table :modalidades do |t|
      t.string :nome

      t.timestamps
    end
  end
end
