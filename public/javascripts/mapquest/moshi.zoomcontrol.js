/**
 * Defines a custom replacement for the MapQuest zoom control.
 */
if (typeof Moshi == 'undefined') {
  Moshi = {};
}

Moshi.ZoomControl = function() {
  browser = MQA.browser;
  this.pan = new Array();
  this.map = null;
  this.position = new MQA.MapCornerPlacement(MQA.MapCorner.TOP_LEFT, new MQA.Size(5,30));
  this.elem = document.createElement("div");
  this.elem.className = "moshiZoomControl";
  this.ePanClick = new Array();
  this.ePanMouseover = new Array();
  this.ePanMouseout = new Array();
  this.eZoominClick = null;
  this.eZoominMouseover = null;
  this.eZoominMouseout = null;
  this.eZoomoutClick = null;
  this.eZoomoutMouseover = null;
  this.eZoomoutMouseout = null;
  this.eZoomareaClick = new Array();
  this.eZoomareaMouseover = new Array();
  this.eZoomboxMouseout = null;
  
  var container = document.createElement("div");
  this.elem.appendChild(container);
  
  var temp = document.createElement("div");
  temp.style.position="relative";
  temp.style.width="56px";
  temp.style.height="53px";
  temp.style.margin="0";
  if (browser.name=="msie" && browser.version<7){
    temp.style.backgroundImage="/images/blank.gif";
    temp.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src='/images/map/zoom_bg_top.png', sizingMethod='image');";
  } else {
    temp.style.background = "transparent url(/images/map/zoom_bg_top.png) no-repeat 0 0";
  }
  container.appendChild(temp);
  temp=document.createElement("div");
  temp.style.position="relative";
  temp.style.width="56px";
  temp.style.height="230px";
  temp.style.margin="0";
  temp.style.padding="5px 0 0";
  if (browser.name=="msie" && browser.version<7){
    temp.style.backgroundImage="none";
    temp.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src='/images/map/zoom_bg.png', sizingMethod='crop')";
  } else {
    temp.style.background = "transparent url(/images/map/zoom_bg.png) repeat-y 0 0";
  }
  if (browser.name=="msie") {
    temp.style.height="235px";
  }
  container.appendChild(temp);
  temp=document.createElement("div");
  temp.style.position="relative";
  temp.style.width="56px";
  temp.style.height="11px";
  temp.style.margin="0";
  temp.style.padding="0";
  if (browser.name=="msie" && browser.version<7){
    temp.style.backgroundImage="none";
    temp.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src='/images/map/zoom_bg_bottom.png', sizingMethod='image')";
  } else {
    temp.style.background = "transparent url(/images/map/zoom_bg_bottom.png) no-repeat 0 0";
  }
  container.appendChild(temp);
  
  container = document.createElement("ul");
  this.elem.appendChild(container);
  
  temp=document.createElement("li");
  temp.className="map-compass-wrapper";
  container.appendChild(temp);
  var temp2 = document.createElement("div");
  temp2.className = "compass";
  temp.appendChild(temp2);
  this.compassrose = document.createElement("img");
  if (browser.name=="msie" && browser.version<7) {
    this.compassrose.src="/images/blank.gif";
    this.compassrose.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src='/images/map/zoom_compass.png', sizingMethod='image')";
  } else {
    this.compassrose.src="/images/map/zoom_compass.png";
  }
  temp2.appendChild(this.compassrose);
  
  this.compassroseimg = document.createElement("img");
  this.compassroseimg.src = "/images/blank.gif";
  this.compassroseimg.className = "compassMap";
  this.compassroseimg.useMap = "#mq-zoomcontrol-linkmap";
  temp2.appendChild(this.compassroseimg);
  
  this.compassrosemap = document.createElement("map");
  this.compassrosemap.name = "mq-zoomcontrol-linkmap";
  this.compassrosemap.id = "mq-zoomcontrol-linkmap";
  temp2.appendChild(this.compassrosemap);
  
  //temp3.appendChild(MQA.Util.createArea("poly","14,21,16,16,21,14,25,16,27,21,25,25,21,27,16,25,14,21,14,21","#center"));
  this.pan[MQA.PAN_NORTH] = MQA.Util.createArea("rect","11,1,29,12","#north","Pan North","Pan North");
  this.compassrosemap.appendChild(this.pan[MQA.PAN_NORTH]);
  this.pan[MQA.PAN_EAST] = MQA.Util.createArea("rect","27,13,40,28","#east","Pan East","Pan East");
  this.compassrosemap.appendChild(this.pan[MQA.PAN_EAST]);
  this.pan[MQA.PAN_WEST] = MQA.Util.createArea("rect","1,13,14,28","#west","Pan West","Pan West");
  this.compassrosemap.appendChild(this.pan[MQA.PAN_WEST]);
  this.pan[MQA.PAN_SOUTH] = MQA.Util.createArea("rect","11,29,29,40","#south","Pan South","Pan South");
  this.compassrosemap.appendChild(this.pan[MQA.PAN_SOUTH]);
  
  temp = document.createElement("li");
  temp.className = "zoom";
  container.appendChild(temp);
  
  temp2 = document.createElement("div");
  temp2.className = "zoomIn";
  temp.appendChild(temp2);
  
  this.zoomin=document.createElement("img");
  this.zoomin.alt="Zoom In";
  this.zoomin.title="Zoom In";
  this.zoomin.border=0;
  if (browser.name=="msie" && browser.version<7) {
    this.zoomin.src="/images/blank.gif";
    this.zoomin.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src='/images/map/zoom_in.png', sizingMethod='image')";
  } else {
    this.zoomin.src="/images/map/zoom_in.png";
  }
  temp2.appendChild(this.zoomin);
  
  this.zoombox = document.createElement("div");
  this.zoombox.className = "zoomBox";
  temp2 = document.createElement("img");
  if (browser.name=="msie" && browser.version<7) {
    temp2.src="/images/blank.gif";
    temp2.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src='/images/map/zoom_bar.png', sizingMethod='image')";
  }else{
    temp2.src="/images/map/zoom_bar.png";
  }
  this.zoombox.appendChild(temp2);
  
  strHtml = '<img src="/images/blank.gif" border="0" class="zoomLinks" />';
  strHtml += '<img src="/images/map/zoom_on.png" border="0" class="zoomOn" />';
  strHtml += '<map>';
  for (var i = 0; i < 16; i++) {
    strHtml += '<area alt="Zoom to level '+(16-i)+'" title="Zoom to level '+(16-i)+'" shape="rect" coords="1, '+(i*11)+', 22, '+(10+i*11)+'" />';
  }
  strHtml += '</map>';
  this.zoombox.innerHTML += strHtml;
  this.zoomarea = this.zoombox.childNodes[3].childNodes;
  temp.appendChild(this.zoombox);
  
  temp2 = document.createElement("div");
  temp2.className = "zoomOut";
  temp.appendChild(temp2);
  
  this.zoomout = document.createElement("img");
  this.zoomout.alt = "Zoom Out";
  this.zoomout.title = "Zoom Out";
  if (browser.name=="msie" && browser.version<7) {
    this.zoomout.src="/images/blank.gif";
    this.zoomout.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src='/images/map/zoom_out.png', sizingMethod='image')";
  }else{
    this.zoomout.src="/images/map/zoom_out.png";
  }
  temp2.appendChild(this.zoomout);
};

Moshi.ZoomControl.prototype = new MQA.Control();

Moshi.ZoomControl.prototype.constructor = Moshi.ZoomControl;

Moshi.ZoomControl.prototype.dispose = function() {
  this.map= null;
  this.position = null;
  this.type = null;
  MQA._prEvent.delDtor(this._dth);
  for (var i=0; i<4; i++) {
    MQA._prEvent.stopObserving(this.pan[i],"click",this.ePanClick[i]);
    MQA._prEvent.stopObserving(this.pan[i],"mouseover",this.ePanMouseover[i]);
    MQA._prEvent.stopObserving(this.pan[i],"mouseout",this.ePanMouseout[i]);
  }
  MQA._prEvent.stopObserving(this.zoomin,"click",this.eZoominClick);
  MQA._prEvent.stopObserving(this.zoomin,"mouseover",this.eZoominMouseover);
  MQA._prEvent.stopObserving(this.zoomin,"mouseout",this.eZoominMouseout);
  MQA._prEvent.stopObserving(this.zoomout,"click",this.eZoomoutClick);
  MQA._prEvent.stopObserving(this.zoomout,"mouseover",this.eZoomoutMouseover);
  MQA._prEvent.stopObserving(this.zoomout,"mouseout",this.eZoomoutMouseout);
  for (var i=0; i<16; i++) {
    MQA._prEvent.stopObserving(this.zoomarea[i],"click",this.eZoomareaClick[i]);
    MQA._prEvent.stopObserving(this.zoomarea[i],"mouseover",this.eZoomareaMouseover[i]);
  }
  MQA._prEvent.stopObserving(this.zoombox,"mouseout",this.eZoomboxMouseout);
  MQA.Util._deleteDOMObject(this.pan[MQA.PAN_NORTH]);
  this.pan[MQA.PAN_NORTH]=null;
  MQA.Util._deleteDOMObject(this.pan[MQA.PAN_EAST]);
  this.pan[MQA.PAN_EAST]=null;
  MQA.Util._deleteDOMObject(this.pan[MQA.PAN_WEST]);
  this.pan[MQA.PAN_WEST]=null;
  MQA.Util._deleteDOMObject(this.pan[MQA.PAN_SOUTH]);
  this.pan[MQA.PAN_SOUTH]=null;
  this.pan=null;
  for(var i=0; i<16; i++) {
    MQA.Util._deleteDOMObject(this.zoomarea[0]);
  }
  this.zoomarea=null;
  MQA.Util._deleteDOMObject(this.zoomin);
  this.zoomin=null;
  MQA.Util._deleteDOMObject(this.zoomout);
  this.zoomout=null;
  this.zoombox.innerHTML=null;
  this.zoombox.outerHTML="";
  MQA.Util._deleteDOMObject(this.zoombox);
  this.zoombox=null;
  this.compassroseimg.src="";
  MQA.Util._deleteDOMObject(this.compassroseimg);
  this.compassroseimg=null;
  this.compassrose.src="";
  MQA.Util._deleteDOMObject(this.compassrose);
  this.compassrose=null;
  this.compassrosemap.innerHTML=null;
  this.compassrosemap.outerHTML="";
  MQA.Util._deleteDOMObject(this.compassrosemap);
  this.compassrosemap=null;
  this.elem.innerHTML=null;
  this.elem.outerHTML="";
  MQA.Util._deleteDOMObject(this.elem);
  this.elem=null;
};

Moshi.ZoomControl.prototype.destructor = function() {
  for(var i=0; i<4; i++){
    MQA._prEvent.stopObserving(this.pan[i],"click",this.ePanClick[i]);
    MQA._prEvent.stopObserving(this.pan[i],"mouseover",this.ePanMouseover[i]);
    MQA._prEvent.stopObserving(this.pan[i],"mouseout",this.ePanMouseout[i]);
  }
  MQA._prEvent.stopObserving(this.zoomin,"click",this.eZoominClick);
  MQA._prEvent.stopObserving(this.zoomin,"mouseover",this.eZoominMouseover);
  MQA._prEvent.stopObserving(this.zoomin,"mouseout",this.eZoominMouseout);
  MQA._prEvent.stopObserving(this.zoomout,"click",this.eZoomoutClick);
  MQA._prEvent.stopObserving(this.zoomout,"mouseover",this.eZoomoutMouseover);
  MQA._prEvent.stopObserving(this.zoomout,"mouseout",this.eZoomoutMouseout);
  for(var i=0; i<16; i++){
    MQA._prEvent.stopObserving(this.zoomarea[i],"click",this.eZoomareaClick[i]);
    MQA._prEvent.stopObserving(this.zoomarea[i],"mouseover",this.eZoomareaMouseover[i]);
  }
  MQA._prEvent.stopObserving(this.zoombox,"mouseout",this.eZoomboxMouseout);
  this.elem.parentNode.removeChild(this.elem);
};

Moshi.ZoomControl.prototype.initialize = function(_8) {
  this.map=_8;
  this.type=MQA.CONTROL_PANZOOM;
  this.setZoom(this.map.getZoomLevel());
  this.compassroseimg.useMap="#mq-zoomcontrol-linkmap"+this.map.uniqueMapID;
  this.compassrosemap.name="mq-zoomcontrol-linkmap"+this.map.uniqueMapID;
  this.compassrosemap.id="mq-zoomcontrol-linkmap"+this.map.uniqueMapID;
  this.zoombox.childNodes[1].useMap="#zoompositions"+this.map.uniqueMapID;
  this.zoombox.childNodes[3].name="zoompositions"+this.map.uniqueMapID;
  this.zoombox.childNodes[3].id="zoompositions"+this.map.uniqueMapID;
  for(var i=0; i<4; i++){
    this.ePanClick[i]=MQA._prEvent.EventCallback(this,"eventmonitor");
    this.ePanMouseover[i]=MQA._prEvent.EventCallback(this,"eventmonitor");
    this.ePanMouseout[i]=MQA._prEvent.EventCallback(this,"eventmonitor");
    MQA._prEvent.observe(this.pan[i],"click",this.ePanClick[i]);
    MQA._prEvent.observe(this.pan[i],"mouseover",this.ePanMouseover[i]);
    MQA._prEvent.observe(this.pan[i],"mouseout",this.ePanMouseout[i]);
  }
  this.eZoominClick=MQA._prEvent.EventCallback(this,"eventmonitor");
  this.eZoominMouseover=MQA._prEvent.EventCallback(this,"eventmonitor");
  this.eZoominMouseout=MQA._prEvent.EventCallback(this,"eventmonitor");
  MQA._prEvent.observe(this.zoomin,"click",this.eZoominClick);
  MQA._prEvent.observe(this.zoomin,"mouseover",this.eZoominMouseover);
  MQA._prEvent.observe(this.zoomin,"mouseout",this.eZoominMouseout);
  this.eZoomoutClick=MQA._prEvent.EventCallback(this,"eventmonitor");
  this.eZoomoutMouseover=MQA._prEvent.EventCallback(this,"eventmonitor");
  this.eZoomoutMouseout=MQA._prEvent.EventCallback(this,"eventmonitor");
  MQA._prEvent.observe(this.zoomout,"click",this.eZoomoutClick);
  MQA._prEvent.observe(this.zoomout,"mouseover",this.eZoomoutMouseover);
  MQA._prEvent.observe(this.zoomout,"mouseout",this.eZoomoutMouseout);
  for(var i=0; i<16; i++){
    this.eZoomareaClick[i]=MQA._prEvent.EventCallback(this,"eventmonitor");
    this.eZoomareaMouseover[i]=MQA._prEvent.EventCallback(this,"eventmonitor");
    MQA._prEvent.observe(this.zoomarea[i],"click",this.eZoomareaClick[i]);
    MQA._prEvent.observe(this.zoomarea[i],"mouseover",this.eZoomareaMouseover[i]);
  }
  this.eZoomboxMouseout=MQA._prEvent.EventCallback(this,"eventmonitor");
  MQA._prEvent.observe(this.zoombox,"mouseout",this.eZoomboxMouseout);
};

Moshi.ZoomControl.prototype.eventmonitor = function(_a) {
  if (typeof (MQA)=="undefined") {
    return;
  }
  eventId="";
  if (MQA._prEvent.element(_a)==this.pan[MQA.PAN_NORTH]) {
    eventId="n";
  }
  if (MQA._prEvent.element(_a)==this.pan[MQA.PAN_SOUTH]) {
    eventId="s";
  }
  if (MQA._prEvent.element(_a)==this.pan[MQA.PAN_EAST]) {
    eventId="e";
  }
  if (MQA._prEvent.element(_a)==this.pan[MQA.PAN_WEST]) {
    eventId="w";
  }
  if (MQA._prEvent.element(_a)==this.zoomin) {
    eventId="in";
  }
  if (MQA._prEvent.element(_a)==this.zoomout) {
    eventId="out";
  }
  if (MQA._prEvent.element(_a)==this.zoombox.childNodes[1]) {
    return;
  }
  for (var i=0;i<16;i++) {
    if(MQA._prEvent.element(_a)==this.zoomarea[i]) {
      eventId=16-i;
      break;
    }
  }
  switch(_a.type){
    case "click":
      switch(eventId){
        case "in":
          if (this.map.getZoomLevel()<16) {
            this.map.zoomIn();
          }
          break;
        case "out":
          this.map.zoomOut();
          break;
        case "n":
          this.map.panNorth(50);
          break;
        case "s":
          this.map.panSouth(50);
          break;
        case "e":
          this.map.panEast(50);
          break;
        case "w":
          this.map.panWest(50);
          break;
        case "nil":
          break;
        default:
          this.map.setZoomLevel(eventId);
          break;
      }
      break;
    case "mouseover":
      switch(eventId) {
        case "in":
        case "out":
          MQA._prEvent.element(_a).className="hover";
          break;
        case "n":
          this.compassrose.className="n";
          break;
        case "s":
          this.compassrose.className="s";
          break;
        case "e":
          this.compassrose.className="e";
          break;
        case "w":
          this.compassrose.className="w";
          break;
        default:
          this.selectZoom(eventId);
          break;
      }
      break;
    case "mouseout":
      switch(eventId) {
        case "in":
        case "out":
          if (MQA._prEvent.element(_a).className=="hover") {
            MQA._prEvent.element(_a).className="";
          }
          break;
      case "n":
      case "s":
      case "e":
      case "w":
        this.compassrose.className="";
        break;
      default:
        if(parseFloat(eventId)!=this.map.getZoomLevel()){
          this.unselectZoom(eventId);
        }
        break;
    }
    break;
  }
};

Moshi.ZoomControl.prototype.setZoom = function(index) {
  var z = this.zoombox.childNodes[2];
  z.style.top = ((16 - index) * 11 + 0) + 'px';
  z.alt = "Zoom to level " + index;
  z.title = "Zoom to level "+ index;
};

Moshi.ZoomControl.prototype.selectZoom = function(index) {
  this.zoombox.childNodes[0].style.left = 0 - ((17 - index) * 24) + 'px';
};

Moshi.ZoomControl.prototype.unselectZoom = function(_f) {
  this.zoombox.childNodes[0].style.left="0";
};

Moshi.ZoomControl.prototype.getHeight = function() {
  return 294;
};

Moshi.ZoomControl.prototype.getWidth = function() {
  return 56;
};