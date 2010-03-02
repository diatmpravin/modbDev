/**
 * Management of the /landmarks/index page
 */
if(typeof Landmarks == "undefined") {
  Landmarks = {};
}

Landmarks.Index = {
  listView: null
  ,
  init: function() {
    Landmarks.Index.listView = new ListView(q("#landmarksList"));
  }

};

jQuery(Landmarks.Index.init);
