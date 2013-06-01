require 'flickraw'

namespace :scrape do
  desc "Scrapes flickr for friendlily-licensed images"
  task :flickr, [:photoset_id] => :environment do |task, task_args|
    FlickRaw.api_key=ENV["FLICKRAW_API_KEY"]
    FlickRaw.shared_secret=ENV["FLICKRAW_SHARED_SECRET"]

    p task_args.inspect

    args = {}
    args[:photoset_id] = task_args[:photoset_id]


    # photo = discovered_pictures.first
    # p photo.inspect

    discovered_pictures = flickr.photosets.getPhotos args

    discovered_pictures["photo"].each do |flickr_photo|
        url = FlickRaw.url flickr_photo

        title = flickr_photo.title.scan(/^(?<offcut>(.*, |.* (at|in|on) )?(?<address>.*?)),? ([ca ,]*)(?<year>[0-9]{4})$/i)


        if title.empty? then
            next
        end

        offcut = title[0][0]
        address = title[0][1]
        year = title[0][2]

        p title
        p offcut + ", " + address + ", " + year

        info = flickr.photos.getInfo(:photo_id => flickr_photo.id)
        description = info.description



        p "Getting candidate spots"
        candidate_spots = Geocoder.search("#{address}, Adelaide, South Australia")

        if candidate_spots.empty? then
            next
        end

        p "Getting first candidate spot"
        spot = candidate_spots.first

        p spot.latitude
        p spot.longitude

        image = Image.where(:source_ref => flickr_photo.id).first

        if image == nil then
            image = Image.new
        end
        
        image.caption = offcut + address
        image.longitude = spot.longitude
        image.latitude = spot.latitude
        image.location_description = address
        image.relevant_from = Date.new(year.to_i)
        image.relevant_to = image.relevant_from + 1.years
        image.fullsize_url = FlickRaw.url_m flickr_photo
        image.thumbnail_url = FlickRaw.url_t flickr_photo
        image.copyright = "Assumed Creative Commons per State Library specification"
        image.caption = description
        image.source = "Flickr"
        image.source_ref = flickr_photo.id

        image.save
    end
  end
end

# {"id"=>"4539666804", "owner"=>"32600408@N06", "secret"=>"52759604d1", "server"=>"2221", "farm"=>3, "title"=>"Murray Bridge fire brigade and crew, 1926", "ispublic"=>1, "isfriend"=>0, "isfamily"=>0}