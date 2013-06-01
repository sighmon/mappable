class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.float :latitude
      t.float :longitude
      t.text :location_description
      t.string :fullsize_url
      t.string :thumbnail_url
      t.string :copyright
      t.text :caption
      t.datetime :relevant_from
      t.datetime :relevant_to

      t.timestamps
    end
  end
end
