class Image < ActiveRecord::Base
  attr_accessible :caption, :copyright, :fullsize_url, :latitude, :location_description, :longitude, :relevant_from, :relevant_to, :thumbnail_url
end
