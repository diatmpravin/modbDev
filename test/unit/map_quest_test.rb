require 'test_helper'

describe "MapQuest", ActiveSupport::TestCase do
  context "Determining remote URL" do
    specify "provides shortcuts for URLs" do
      MapQuest::server_for(:map).should.equal 'map.access.mapquest.com'
      MapQuest::server_for(:geocode).should.equal 'geocode.access.mapquest.com'
      MapQuest::server_for(:route).should.equal 'route.access.mapquest.com'
    end
    
    specify "will accept a specific URL" do
      MapQuest::server_for('customhost.com').should.equal 'customhost.com'
    end
  end

  context "Making remote calls" do
    # MapQuest::call is disabled in test helper, so no point in writing tests
    # for it. The method itself is a thin wrapper for Net::HTTP.
  end
  
  
  context "LatLng Collections" do
    setup do
      @xml = Builder::XmlMarkup.new
    end
    
    specify "can create a lat lng collection" do
      points = [
        Point.new(:latitude => 86, :longitude => 40),
        Point.new(:latitude => 86.4, :longitude => -20),
        Point.new(:latitude => 84.701923, :longitude => 19.230943)
      ]
      
      MapQuest::LatLngCollection.new(points).build @xml
      string = @xml.to_s
      
      string.should.equal '<Lat>86000000</Lat><Lng>40000000</Lng>' +
        '<Lat>400000</Lat><Lng>-60000000</Lng>' +
        '<Lat>-1698077</Lat><Lng>39230943</Lng><to_s/>'
    end
  end
  
  
  context "Tile" do
    specify "can convert tile col/row to outer tile x/y" do
      MapQuest::Tile::to_xy(-2, -2).should.equal [0, 0]
      MapQuest::Tile::to_xy(0, 0).should.equal [0, 0]
      MapQuest::Tile::to_xy(1, 1).should.equal [0, 0]
      
      MapQuest::Tile::to_xy(2, -2).should.equal [256, 0]
      MapQuest::Tile::to_xy(5, 1).should.equal [256, 0]
      
      MapQuest::Tile::to_xy(-3, -3).should.equal [-256, -256]
    end
  end
  
  
  context "TileCache" do
    context "Generating file names" do
      specify "correctly creates row/col filenames" do
        MapQuest::TileCache::file_name(-2, -2).should.equal 'tile0_0_0.gif'
        MapQuest::TileCache::file_name(0, 0).should.equal 'tile0_0_10.gif'
        MapQuest::TileCache::file_name(1, 1).should.equal 'tile0_0_15.gif'
        
        MapQuest::TileCache::file_name(2, -2).should.equal 'tile1_0_0.gif'
        MapQuest::TileCache::file_name(5, 1).should.equal 'tile1_0_15.gif'
        
        MapQuest::TileCache::file_name(-3, -3).should.equal 'tile_1__1_15.gif'
      end
      
      specify "correctly creates row/col file patterns" do
        MapQuest::TileCache::file_pattern(-2, -2).should.equal 'tile0_0_%d.gif'
        MapQuest::TileCache::file_pattern(0, 0).should.equal 'tile0_0_%d.gif'
        MapQuest::TileCache::file_pattern(1, 1).should.equal 'tile0_0_%d.gif'
        
        MapQuest::TileCache::file_pattern(2, -2).should.equal 'tile1_0_%d.gif'
        MapQuest::TileCache::file_pattern(5, 1).should.equal 'tile1_0_%d.gif'
        
        MapQuest::TileCache::file_pattern(-3, -3).should.equal 'tile_1__1_%d.gif'
      end
      
      specify "creates folder names for session ids" do
        MapQuest::TileCache::folder_for('free-beer').should.match(/free_beer$/)
      end
    end
    
    context "Storing tiles in cache" do
      specify "works" do
        # Mock out any actual file creation
        MojoMagick.expects(:tempfile).returns('source.gif')
        MojoMagick.expects(:raw_command).with {|cmd, args|
          cmd == 'convert' &&
          args =~ /^source.gif/ &&
          args =~ /\/free_beer\/tile0_0_%d.gif$/
        }
        
        MapQuest::TileCache.put('free-beer', 1, 1, 'image blob')
      end
    end
    
    context "Retrieving tiles from cache" do
      specify "works" do
        MapQuest::TileCache.get('free-beer', 1, 1).should.equal 'binary data'
      end
      
      specify "returns nil if file does not exist" do
        MapQuest::TileCache.get('free-beer', -7, 7).should.equal nil
      end
    end
    
    context "Clearing cache" do
      specify "works" do
        FileUtils.expects(:rm)
        
        MapQuest::TileCache.clear('free-beer')
      end
    end
  end # TileCache
  
  
  context "Sessions" do
    setup do
      @typical_session = MapQuest::Session.new('abcd1234', {
        'Scale' => '48000',
        'CoverageName' => 'navt',
        'Center' => {
          'Lat' => '-82.000000',
          'Lng' => '40.060000'
        }
      })
    end
  
    context "Instantiating a session" do
      specify "will create a new remote session" do
        MapQuest.expects(:call).returns(
          "<CreateSessionResponse><SessionID>fragglerock</SessionID><MapState></MapState></CreateSessionResponse>"
        )
        
        mqs = MapQuest::Session.new
        mqs.session_id.should.equal 'fragglerock'
      end
      
      specify "will resume an existing session" do
        MapQuest.expects(:call).never
        
        mqs = MapQuest::Session.new('abcd1234')
        mqs.session_id.should.equal 'abcd1234'
      end
    end
    
    context "Centering map to a specific point" do
      setup do
        @mqs = @typical_session
        @ok = '<UpdateSessionResponse><MapState><Center><Lat>-82.400000</Lat>
               <Lng>40.060000</Lng></Center><Scale>12000</Scale></MapState>
               </UpdateSessionResponse>'
      end
      
      specify "works" do
        MapQuest.expects(:call).with {|s, xml|
          if xml =~ /<UpdateSession>/ &&
             xml =~ /<CenterLatLng><Lat>-82.40<\/Lat><Lng>40.06<\/Lng><\/CenterLatLng>/
            true
          end
        }.returns(@ok)
        
        @mqs.center('-82.40', '40.06')
        
        @mqs.map_state['Center']['Lat'].should.equal '-82.400000'
        @mqs.map_state['Center']['Lng'].should.equal '40.060000'
        @mqs.map_state['Scale'].should.equal '12000'
      end
    end
    
    context "Panning map" do
      setup do
        @mqs = @typical_session
        @ok = '<UpdateSessionResponse><MapState><Center><Lat>-82.400000</Lat>
               <Lng>40.060000</Lng></Center><Scale>12000</Scale></MapState>
               </UpdateSessionResponse>'
      end
      
      specify "works" do
        MapQuest.expects(:call).with {|s, xml|
          if xml =~ /<UpdateSession>/ &&
             xml =~ /<DeltaPoint><X>64<\/X><Y>128<\/Y><\/DeltaPoint>/
            true
          end
        }.returns(@ok)
        
        @mqs.pan(64, 128)
        
        @mqs.map_state['Center']['Lat'].should.equal '-82.400000'
        @mqs.map_state['Center']['Lng'].should.equal '40.060000'
        @mqs.map_state['Scale'].should.equal '12000'
      end
    end
    
    context "Zooming map" do
      setup do
        @mqs = @typical_session
        @ok = '<UpdateSessionResponse><MapState><Center><Lat>-82.400000</Lat>
               <Lng>40.060000</Lng></Center><Scale>192000</Scale></MapState>
               </UpdateSessionResponse>'
      end
      
      specify "works" do
        MapQuest.expects(:call).with {|s, xml|
          if xml =~ /<UpdateSession>/ &&
             xml =~ /<Scale>192000<\/Scale>/
            true
          end
        }.returns(@ok)
        
        MapQuest::TileCache.expects(:clear).with('abcd1234')
        
        @mqs.zoom_to_scale 192000
        
        @mqs.map_state['Center']['Lat'].should.equal '-82.400000'
        @mqs.map_state['Center']['Lng'].should.equal '40.060000'
        @mqs.map_state['Scale'].should.equal '192000'
      end
      
      specify "will accept zoom levels" do
        MapQuest::Session.any_instance.expects(:zoom_to_scale).with(192000)
        
        @mqs.zoom_to_level 8
      end
    end
    
    context "Using best-fit for a set of points" do
      setup do
        @mqs = @typical_session
        @trip = trips(:quentin_trip)
        @ok = '<UpdateSessionResponse><MapState><Center><Lat>33.684180</Lat>
               <Lng>-84.40866</Lng></Center><Scale>12000</Scale></MapState>
               </UpdateSessionResponse>'
      end
      
      specify "works" do
        MapQuest.expects(:call).with {|s, xml|
            if xml =~ /<UpdateSession>/ &&
               xml =~ /<Width>4.444444<\/Width>/ &&
               xml =~ /<Height>3.333333<\/Height>/ &&
               xml =~ /<Lat>33684180<\/Lat>/ &&
               xml =~ /<Lng>-84408660<\/Lng>/
              true
            end
        }.returns(@ok)
        
        MapQuest.expects(:call).with {|s, xml|
            if xml =~ /<UpdateSession>/ &&
               xml =~ /<Width>3.555556<\/Width>/ &&
               xml =~ /<Height>3.555556<\/Height>/
              true
            end
        }.returns(@ok)
        
        @mqs.best_fit(@trip.points, 320, 240)
      end
    end
    
    context "Converting a list of lat/longs into pixel space" do
      setup do
        @mqs = @typical_session
        @points = [
          Point.new(:latitude => 40.222222, :longitude => -86.333333),
          Point.new(:latitude => 40.000000, :longitude => -86.000000)
        ]
        @ok = '<LLToPixResponse><PointCollection><X>0</X><Y>0</Y>
               <X>100</X><Y>100</Y></PointCollection></LLToPixResponse>'
      end
      
      specify "works" do
        MapQuest::LatLngCollection.new(@points)
        MapQuest.expects(:call).with {|s, xml|
          if xml =~ /<LLToPix>/ &&
             xml =~ /<LatLngCollection>/ &&
             xml =~ /<Lat>40222222<\/Lat>/ &&
             xml =~ /<Lng>-86333333<\/Lng>/ &&
             xml =~ /<Lat>-222222<\/Lat>/ &&
             xml =~ /<Lng>333333<\/Lng>/
            true
          end
        }.returns(@ok)
        
        @mqs.pixels_for(@points).should.equal [
          [-128, -128],
          [-28, -28]
        ]
      end
    end
    
    specify "knows current zoom level" do
      mqs = @typical_session
      mqs.map_state['Scale'] = 6000
      mqs.zoom_level.should.equal 13
      
      mqs.map_state['Scale'] = 96000
      mqs.zoom_level.should.equal 9
    end
  end # Session
  
end
