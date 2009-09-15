# haversine.rb
#
# haversine formula to compute the great circle distance between two points given their latitude and longitudes
#
# Copyright (C) 2008, 360VL, Inc
# Copyright (C) 2008, Landon Cox
#
# http://www.360vl.com (360VL, Inc.)
# http://sawdust.see-do.org (Landon Cox)
#
# LICENSE: GNU Affero GPL v3
# The ruby implementation of the Haversine formula is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License version 3 as published by the Free Software Foundation.  
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public 
# License version 3 for more details.  http://www.gnu.org/licenses/
#
# Landon Cox - 9/25/08
# 
# Notes:
#
# translated into Ruby based on information contained in:
#   http://mathforum.org/library/drmath/view/51879.html  Doctors Rick and Peterson - 4/20/99
#   http://www.movable-type.co.uk/scripts/latlong.html
#   http://en.wikipedia.org/wiki/Haversine_formula
#
# This formula can compute accurate distances between two points given latitude and longitude, even for 
# short distances.
#
module Haversine
  # PI = 3.1415926535
  RAD_PER_DEG = 0.017453293  #  PI/180
  
  RADIUS = {
    :miles => 3956,
    :kilometers => 6371,
    :feet => 3956 * 5282,
    :meters => 6371 * 1000
  }
  
  # Given two lat/long coordinates and an optional units parameter,
  # return the distance between the two points.
  def Haversine::distance(lat1, lon1, lat2, lon2, units = :meters)
    dlon = lon2 - lon1
    dlat = lat2 - lat1

    dlon_rad = dlon * RAD_PER_DEG 
    dlat_rad = dlat * RAD_PER_DEG

    lat1_rad = lat1 * RAD_PER_DEG
    lon1_rad = lon1 * RAD_PER_DEG

    lat2_rad = lat2 * RAD_PER_DEG
    lon2_rad = lon2 * RAD_PER_DEG

    a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * (Math.sin(dlon_rad/2))**2
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
    
    RADIUS[units] * c
  end
  
  # Map an array of [lat, long] pairs to an array of [x, y] pairs using the
  # Haversine formula. The first lat/long will be used as the cartesian origin.
  def Haversine::ll_to_xy(array)
    origin = array.first
    
    array.map {|ll| [
      distance(origin[0], origin[1], origin[0], ll[1]),
      distance(origin[0], origin[1], ll[0], origin[1])
    ]}
  end
end