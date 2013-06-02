require 'flickraw'
require 'csv'

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

    p discovered_pictures["photo"].size.to_s + " photos"

    discovered_pictures["photo"].each do |flickr_photo|
        url = FlickRaw.url flickr_photo

        title = flickr_photo.title.scan(/^(((?<offcut>.*)( at| in| on| in front of| behind| near|,) )?(?<address>.*?)),? ((circa)?[ca\. ,]*)(?<year>[0-9]{4})$/i)
        # title? flickr_photo.title.scan(/^((?<offcut>.*( at| in| on|,) )?(?<address>.*?)),? ([ca ,]*)(?<year>[0-9]{4})$/i)


        if title.empty? then
            next
        end

        offcut = title[0][0] == nil ? "" : title[0][0]
        address = title[0][1]
        year = title[0][2]


        p title
        p offcut + ", " + address + ", " + year

        info = flickr.photos.getInfo(:photo_id => flickr_photo.id)
        description = info.description


        location = "#{address}, South Australia"
        if flickr_photo.title.include? "Murray Bridge" then
            location = "#{address}, Murray Bridge, South Australia"
        elsif flickr_photo.title.include? "Glenelg" then
            location = "#{address}, Glenelg, South Australia"
        elsif flickr_photo.title.include? "Victor Harbour" then
            location = "#{address}, Victor Harbour, South Australia"
        else
        end

        p "Getting candidate spots for #{location}"

        candidate_spots = Geocoder.search(location)

        if candidate_spots.empty? then
            p "Found no candidate spots, continuing"
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


        image.caption = flickr_photo.title
        image.longitude = spot.longitude
        image.latitude = spot.latitude
        image.location_description = address
        image.relevant_from = Date.new(year.to_i)
        image.relevant_to = image.relevant_from + 1.years
        image.fullsize_url = FlickRaw.url_m flickr_photo
        image.thumbnail_url = FlickRaw.url_t flickr_photo
        image.copyright = "Assumed Creative Commons per State Library specification"
        image.source = "Flickr"
        image.source_ref = flickr_photo.id
        image.source_url = info.urls[0]._content

        image.save
    end
  end


  desc "Scrape a CSV file"
  task :csv, [:csv_file] => :environment do |task, task_args|

    csvname = task_args[:csv_file] #used to define source_ref
    csv_text = File.read(csvname)




    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
        caption = row[4]
        broken_caption = caption.scan(/^((?<leading_offcut>.*)( at| in| on| in front of| behind| near) )?(?<address>.*?)(?<trailing_offcut> \:.*)?$/i)

        location = broken_caption[0][1]
        year = row[5].scan(/.*([0-9]{4})$/)[0][0].to_i # fancy regex removes 'circa' 'ca' 'ca.' and alternatives

        url = row[9]

        p caption
        candidate_spots = Geocoder.search(location)

        if candidate_spots.empty? then
          p "Found no candidate spots, continuing"
          next
        end

        if row[6].downcase.include? "glass (half plate" then
            p "Skipping likely portrait"
            next
        end

        if location.downcase.include? "prisoner" or location.downcase.include? "intern" then
            p "Skipping POW camp (can't reliably determine location)"
            next
        end

        if location.match(/^[\w\.]+ \w+$/) != nil then
            p "This might be a person's name, skipping"
            next
        end

        if caption.match(/^\w+$/) != nil then
            p "Too short a caption"
            next
        end

        p "Getting first candidate spot"
        spot = candidate_spots.first

        p caption
        p spot.country

        if spot.country == "United States" then
            p "Skipping US"
            next
        end

        if spot.country == "Mexico" then
            p "Skipping MX"
            next
        end

        if spot.country == "Canada" then
            p "Skipping CA"
            next
        end



        p "Importing"

        image = Image.new

        image.caption = row[4]
        image.location_description = location
        image.longitude = spot.longitude
        image.latitude = spot.latitude
        image.relevant_from = Date.new(year.to_i)
        image.relevant_to = image.relevant_from + 1.years
        image.fullsize_url = url
        image.thumbnail_url = url
        image.copyright = "Assumed Creative Commons per State Library specification"
        image.source = "CSV"
        image.source_ref = csvname
        image.source_url = row[1]

        image.save

    end
  end
end

# {"id"=>"4539666804", "owner"=>"32600408@N06", "secret"=>"52759604d1", "server"=>"2221", "farm"=>3, "title"=>"Murray Bridge fire brigade and crew, 1926", "ispublic"=>1, "isfriend"=>0, "isfamily"=>0}