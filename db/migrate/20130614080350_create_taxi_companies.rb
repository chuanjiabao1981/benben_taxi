class CreateTaxiCompanies < ActiveRecord::Migration
  def change
    create_table :taxi_companies do |t|
      t.string :name
      t.string :boss
      t.references :tenant
      t.timestamps
    end
  end
end
