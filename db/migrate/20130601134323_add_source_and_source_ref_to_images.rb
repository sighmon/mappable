class AddSourceAndSourceRefToImages < ActiveRecord::Migration
  def change
    add_column :images, :source, :string
    add_column :images, :source_ref, :string
  end
end
