// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require leaflet
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .
//= require retina_image_tag
// require leaflet-plugins

// Fit the map to the screen size.

var map_bottom_margin = -30
if ($(window).width() > 767) {
  map_bottom_margin = 60;
}

$(function() {
    $(window).resize(function() {
        if ($('#map').length > 0) {
        	$('#map').height($(window).height() - ($('#map').offset().top + map_bottom_margin));
        }
    });
    $(window).resize();
});