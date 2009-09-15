/**
 * Defines a custom replacement for the MapQuest view control.
 */
if (typeof Moshi == 'undefined') {
  Moshi = {};
}

Moshi.ViewControl = function() {
  browser = MQA.browser;
  this.map = null;
  this.position = new MQA.MapCornerPlacement(MQA.MapCorner.TOP_RIGHT, new MQA.Size(150,0));
  this.elem = document.createElement("div");
  this.elem.className = "moshiViewControl";
  this.ul = document.createElement("ul");
  this.elem.appendChild(this.ul);
  
  this.li1 = document.createElement("li");
  this.li1.className = "streetView";
  this.ul.appendChild(this.li1);
  this.streetview=document.createElement("img");
  if (browser.name=="msie" && browser.version<7){
    this.streetview.src="/images/blank.gif";
    this.streetview.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src='/images/map/view_street.png', sizingMethod='image')";
  } else {
    this.streetview.src="/images/map/view_street.png";
  }
  this.streetview.alt = "View Street Map";
  this.streetview.title = "View Street Map";
  this.li1.appendChild(this.streetview);
  
  this.li2 = document.createElement("li");
  this.li2.className = "aerialView";
  this.ul.appendChild(this.li2);
  this.aerialview = document.createElement("img");
  if(browser.name=="msie" && browser.version<7){
    this.aerialview.src="/images/blank.gif";
    this.aerialview.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src='/images/map/view_aerial.png', sizingMethod='image')";
  }else{
    this.aerialview.src="/images/map/view_aerial.png";
  }
  this.aerialview.alt = "View Aerial Image";
  this.aerialview.title = "View Aerial Image";
  this.li2.appendChild(this.aerialview);
  
  this.li3 = document.createElement("li");
  this.li3.className = "hybridView";
  this.ul.appendChild(this.li3);
  this.hybridview = document.createElement("img");
  if (browser.name=="msie" && browser.version<7){
    this.hybridview.src="/images/blank.gif";
    this.hybridview.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src='/images/map/view_hybrid.png', sizingMethod='image')";
  }else{
    this.hybridview.src="/images/map/view_hybrid.png";
  }
  this.hybridview.alt = "View Hybrid Map";
  this.hybridview.title = "View Hybrid Map";
  this.li3.appendChild(this.hybridview);
};

Moshi.ViewControl.prototype = new MQA.Control();

Moshi.ViewControl.prototype.constructor = Moshi.ViewControl;

Moshi.ViewControl.prototype.dispose = function() {
  this.map=null;
  this.type=null;
  this.position=null;
  MQA._prEvent.stopObserving(this.streetview,"click",this.eStreetClick);
  MQA._prEvent.stopObserving(this.streetview,"mouseover",this.eStreetMouseOver);
  MQA._prEvent.stopObserving(this.streetview,"mouseout",this.eStreetMouseOut);
  MQA._prEvent.stopObserving(this.aerialview,"click",this.eArialClick);
  MQA._prEvent.stopObserving(this.aerialview,"mouseover",this.eArialMouseOver);
  MQA._prEvent.stopObserving(this.aerialview,"mouseout",this.eArialMouseOut);
  MQA._prEvent.stopObserving(this.hybridview,"click",this.eHybridClick);
  MQA._prEvent.stopObserving(this.hybridview,"mouseover",this.eHybridMouseOver);
  MQA._prEvent.stopObserving(this.hybridview,"mouseout",this.eHybridMouseOut);
  this.streetview.src="";
  MQA.Util._deleteDOMObject(this.streetview);
  this.streetview=null;
  this.aerialview.src="";
  MQA.Util._deleteDOMObject(this.aerialview);
  this.aerialview=null;
  this.hybridview.src="";
  MQA.Util._deleteDOMObject(this.hybridview);
  this.hybridview=null;
  this.li1.innerHTML=null;
  this.li1.outerHTML="";
  MQA.Util._deleteDOMObject(this.li1);
  this.li1=null;
  this.li2.innerHTML=null;
  this.li2.outerHTML="";
  MQA.Util._deleteDOMObject(this.li2);
  this.li2=null;
  this.li3.innerHTML=null;
  this.li3.outerHTML="";
  MQA.Util._deleteDOMObject(this.li3);
  this.li3=null;
  this.ul.innerHTML=null;
  this.ul.outerHTML="";
  MQA.Util._deleteDOMObject(this.ul);
  this.ul=null;
  this.elem.innerHTML=null;
  this.elem.outerHTML="";
  MQA.Util._deleteDOMObject(this.elem);
  this.elem=null;
};

Moshi.ViewControl.prototype.destructor = function() {
  MQA._prEvent.stopObserving(this.streetview, "click", this.eStreetClick);
  MQA._prEvent.stopObserving(this.streetview, "mouseover", this.eStreetMouseOver);
  MQA._prEvent.stopObserving(this.streetview, "mouseout", this.eStreetMouseOut);
  MQA._prEvent.stopObserving(this.aerialview, "click", this.eArialClick);
  MQA._prEvent.stopObserving(this.aerialview, "mouseover", this.eArialMouseOver);
  MQA._prEvent.stopObserving(this.aerialview, "mouseout", this.eArialMouseOut);
  MQA._prEvent.stopObserving(this.hybridview, "click", this.eHybridClick);
  MQA._prEvent.stopObserving(this.hybridview, "mouseover", this.eHybridMouseOver);
  MQA._prEvent.stopObserving(this.hybridview, "mouseout", this.eHybridMouseOut);
  this.elem.parentNode.removeChild(this.elem);
};

Moshi.ViewControl.prototype.initialize = function(map) {
  this.map = map;
  this.type = MQA.CONTROL_TYPE;
  this.eStreetClick = MQA._prEvent.EventCallback(this, "eventmonitor");
  this.eStreetMouseOver = MQA._prEvent.EventCallback(this, "eventmonitor");
  this.eStreetMouseOut = MQA._prEvent.EventCallback(this, "eventmonitor");
  MQA._prEvent.observe(this.streetview, "click", this.eStreetClick);
  MQA._prEvent.observe(this.streetview, "mouseover", this.eStreetMouseOver);
  MQA._prEvent.observe(this.streetview, "mouseout", this.eStreetMouseOut);
  this.eArialClick = MQA._prEvent.EventCallback(this, "eventmonitor");
  this.eArialMouseOver = MQA._prEvent.EventCallback(this, "eventmonitor");
  this.eArialMouseOut = MQA._prEvent.EventCallback(this, "eventmonitor");
  MQA._prEvent.observe(this.aerialview, "click", this.eArialClick);
  MQA._prEvent.observe(this.aerialview, "mouseover", this.eArialMouseOver);
  MQA._prEvent.observe(this.aerialview, "mouseout", this.eArialMouseOut);
  this.eHybridClick = MQA._prEvent.EventCallback(this, "eventmonitor");
  this.eHybridMouseOver = MQA._prEvent.EventCallback(this, "eventmonitor");
  this.eHybridMouseOut = MQA._prEvent.EventCallback(this, "eventmonitor");
  MQA._prEvent.observe(this.hybridview, "click", this.eHybridClick);
  MQA._prEvent.observe(this.hybridview, "mouseover", this.eHybridMouseOver);
  MQA._prEvent.observe(this.hybridview, "mouseout", this.eHybridMouseOut);
  if(this.map.getMapType() == MQA.MAP_TYPE.MAP) {
    this.streetview.className="selected";
  }
  if(this.map.getMapType() == MQA.MAP_TYPE.SAT) {
    this.aerialview.className="selected";
  }
  if(this.map.getMapType() == MQA.MAP_TYPE.HYB) {
    this.hybridview.className="selected";
  }
};

Moshi.ViewControl.prototype.eventmonitor = function(evt) {
  if (typeof MQA == "undefined") {
    return;
  }
  
  var elem = MQA._prEvent.element(evt);
  
  switch(evt.type) {
    case "click":
      if (elem == this.streetview) {
        this.selectMode("street");
      }
      if (elem == this.aerialview) {
        this.selectMode("aerial");
      }
      if (elem == this.hybridview) {
        this.selectMode("hybrid");
      }
      break;
    case "mouseover":
      if (elem.className!="selected") {
        elem.className = "hover";
      }
      break;
    case "mouseout":
      if (elem.className!="selected") {
        elem.className = "";
      }
      break;
  }
};

Moshi.ViewControl.prototype.updateControl = function(mode) {
  switch(mode) {
    case MQA.MAP_TYPE.MAP:
      this.aerialview.className="";
      this.hybridview.className="";
      this.streetview.className="selected";
      break;
    case MQA.MAP_TYPE.SAT:
      this.hybridview.className="";
      this.streetview.className="";
      this.aerialview.className="selected";
      break;
    case MQA.MAP_TYPE.HYB:
      this.aerialview.className="";
      this.streetview.className="";
      this.hybridview.className="selected";
      break;
  }
};

Moshi.ViewControl.prototype.selectMode=function(mode) {
  var oldMode = this.map.getMapType();
  var newMode = "noChange";
  if (mode == "street" && oldMode != MQA.MAP_TYPE.MAP) {
    newMode = MQA.MAP_TYPE.MAP;
  }
  if (mode=="aerial" && oldMode != MQA.MAP_TYPE.SAT) {
    newMode = MQA.MAP_TYPE.SAT;
  }
  if (mode=="hybrid" && oldMode != MQA.MAP_TYPE.HYB) {
    newMode = MQA.MAP_TYPE.HYB;
  }
  if (newMode != "noChange") {
    this.map.setMapType(newMode);
  }
};

Moshi.ViewControl.prototype.getHeight=function() {
  return 22;
};

Moshi.ViewControl.prototype.getWidth=function(){
  return 210;
};