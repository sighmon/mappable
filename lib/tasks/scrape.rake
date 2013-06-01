require 'flickraw'

namespace :scrape do
  desc "Scrapes flickr for friendlily-licensed images"
  task :flickr => :environment do
    FlickRaw.api_key=ENV["FLICKRAW_API_KEY"]
    FlickRaw.shared_secret=ENV["FLICKRAW_SHARED_SECRET"]

    # new_b = flickr.places.find :query => "Adelaide, South Australia"
    # latitude = new_b[0]['latitude'].to_f
    # longitude = new_b[0]['longitude'].to_f

    # radius = 1
    args = {}
    # args[:bbox] = "#{longitude - radius},#{latitude - radius},#{longitude + radius},#{latitude + radius}"

    args[:photoset_id] = "72157626397640297"


    # photo = discovered_pictures.first
    # p photo.inspect

    discovered_pictures = flickr.photosets.getPhotos args

    discovered_pictures["photo"].each do |photo|
        url = FlickRaw.url photo
        # p url
        # p photo.title
        # exif = flikcr.photos.getExif :photo_id => photo.id
        # p exif.inspect

        title = photo.title.scan(/^(?<offcut>(.*, |.* at |.* in )?(?<address>.*?)),? ([ca ,]*)(?<year>[0-9]{4})$/i)


        if title.empty? then
            next
        end

        offcut = title[0][0]
        address = title[0][1]
        year = title[0][2]

        p title
        p offcut + ", " + address + ", " + year

        info = flickr.photos.getInfo(:photo_id => photo.id)
        description = info.description



        p "Getting candidate spots"
        candidate_spots = Geocoder.search(address + "Adelaide")

        if candidate_spots.empty? then
            next
        end

        p "Getting first candidate spot"
        spot = candidate_spots.first

        p spot.latitude
        p spot.longitude

        image = Image.new
        image.caption = offcut + address
        image.longitude = spot.longitude
        image.latitude = spot.latitude
        image.location_description = address
        image.relevant_from = Date.new(year.to_i)
        image.relevant_to = image.relevant_from + 1.years
        image.fullsize_url = FlickRaw.url_m photo
        image.thumbnail_url = FlickRaw.url_t photo
        image.copyright = "Assumed Creative Commons per State Library specification"
        image.caption = description

        image.save
    end
  end
end

# {"id"=>"4539666804", "owner"=>"32600408@N06", "secret"=>"52759604d1", "server"=>"2221", "farm"=>3, "title"=>"Murray Bridge fire brigade and crew, 1926", "ispublic"=>1, "isfriend"=>0, "isfamily"=>0}