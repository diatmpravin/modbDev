PhoneFinder = {
  init: function() {
    q('div.back a').live('click', PhoneFinder.back);
    
    q('#select-carrier').attr('selectedIndex', 0).change(PhoneFinder.selectCarrier);
    q('#select-manufacturer').attr('selectedIndex', 0).change(PhoneFinder.selectManufacturer);

    q('#phone-list').find('.phone:last').css('margin-bottom', '55px');
    
    q('#phoneFinder').corners('transparent');
    
    var pos = q('#phoneFinder').position();
    q('#phoneFinder .loading').css('left', pos.left + 165);
    q('#phoneFinder .loading').css('top', pos.top + 165);
  }
  ,
  get: function(url, params) {
    q('#phoneFinder .loading').show();
    
    q.get(url, params, function(html) {
      q('#phoneFinder .loading').hide();
      q('#phoneFinderContent').html(html);
      
      q('#select-carrier').attr('selectedIndex', 0).change(PhoneFinder.selectCarrier);
      q('#select-manufacturer').attr('selectedIndex', 0).change(PhoneFinder.selectManufacturer);
    });
  }
  ,
  back: function() {
    PhoneFinder.get(this.href);
    return false;
  }
  ,
  phone: function(link) {
    PhoneFinder.get(link.href);
    return false;
  }
  ,
  selectCarrier: function() {
    if (this.selectedIndex == 0)
      return;
    
    PhoneFinder.get(q('form').attr('action')+'/'+q(this).fieldValue());
  }
  ,
  selectManufacturer: function() {
    if (this.selectedIndex == 0)
      return;
    
    PhoneFinder.get(q('form').attr('action')+'/phones?manufacturer_id='+q(this).fieldValue());
  }
  ,
  search: function() {
    PhoneFinder.get(q('form').attr('action')+'/phones?query='+q('#query').val());
  }
};

/* Initializer */
jQuery(function() {
  PhoneFinder.init();
});