class AddSourceUrlToImages < ActiveRecord::Migration
  def change
    add_column :images, :source_url, :string
  end
end
