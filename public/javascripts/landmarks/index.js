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

    //q('#addLandmark').live('click', Landmarks.Index.newLandmark);

    q("#removeLandmark").dialog({
      title: 'Remove Landmark',
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'Yes, delete this landmark': Landmarks.Index.destroy,
        'No, do not delete': function() { q(this).dialog('close'); }
      }
    });

    q('a.delete').live('click', function() {
      q('#removeLandmark').find('form').attr('action', this.href).end()
                        .dialog('open');
      return false;
    });

    new Reports.Form({
      container: '#runReportForm',
      deviceField: 'input[name=landmark_ids]',
      getSelection: function() { return Landmarks.Index.listView.getSelected(); }
    });
  }
  ,
  /**
   * Remove a landmark
   */
  destroy: function() {
    var _this = q(this);
    
    _this.dialogLoader().show();
    _this.find('form').submit();
    
    return false;
  }
};

jQuery(Landmarks.Index.init);
