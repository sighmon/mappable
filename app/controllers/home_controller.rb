class HomeController < ApplicationController
  def index
  	# Set meta tags
    set_meta_tags :title => "Exploring maps",
                  :description => "A 2013 GovHack Adelaide entry by Hackerspace Adelaide",
                  :keywords => "mappable, govhack, unleashed, adelaide, hackerspace, australia",
                  :canonical => root_url,
                  :open_graph => {
                    :title => "Exploring maps",
                    :description => "A 2013 GovHack Adelaide entry by Hackerspace Adelaide",
                    :url   => root_url,
                    # :image => URI.join(root_url, view_context.image_path('mappable@2x.png')),
                    :site_name => "Mappable"
                  }
  end

end
