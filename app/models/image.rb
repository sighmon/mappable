class Image < ActiveRecord::Base
  attr_accessible :caption, :copyright, :fullsize_url, :latitude, :location_description, :longitude, :relevant_from, :relevant_to, :thumbnail_url, :source, :source_ref

  def self.find_in_range(min_lat, min_long, max_lat, max_long)
    Image.find(:all, conditions: ['latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?', min_lat, max_lat, min_long, max_long])   
  end

  def self.import_from_json(filename)
    ActiveSupport::JSON.decode(File.open(filename))["features"].each do |feature|
      properties = feature["properties"]
      Image.create(latitude: properties["LATITUDE"], longitude: properties["LONGITUDE"], caption: properties["NAME"])
    end
  end

  def self.import_sa_memory(filename)
    ActiveSupport::JSON.decode(File.open(filename)).each_value do |value|
      Image.create(
        latitude: value["LATITUDE"],
        longitude: value["LONGITUDE"],
        source: "SAMemory",
        source_ref: value["id"],
        fullsize_url: ActionController::Base.helpers.strip_tags(value["FILE_BROWSE"]),
        caption: value["TITLE"],
        location_description: value["COVERAGE_REGION"]
      )
    end
  end

  def self.import_slsa_worldwar(filename)
    File.open(filename).each_line do |line|
      url, latitude, longitude, caption = line.split("\t")
      if ((latitude!="-30") and (longitude!="135"))
        Image.create(
          latitude: latitude, 
          longitude: longitude, 
          source: "SLSA Worldwar",
          fullsize_url: url,
          caption: caption
        )
      end
    end
  end

  def to_geojson_hash
    { "type" => "Feature", 
      "id" => id,
      "properties" => {"popupContent" => caption, "name" => caption}, 
      "geometry" => { 
        "type" => "Point", 
        "coordinates" => [longitude, latitude] 
      } 
    }
  end
end
