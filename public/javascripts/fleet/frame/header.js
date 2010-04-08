/**
 * Fleet.Frame.Header
 *
 * Represents the header above the resizable frame.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.Header = (function(Header, Fleet, $) {
  var header,
      headers,
      current = null,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the header.
   */
  Header.init = function() {
    if (init) {
      return Header;
    }
    
    header = $('#frame_header');
    headers = {};
    
    // The plain old header
    headers.standard = 
      $('<div class="standard" style="display:none"><span class="title"></span></div>').appendTo(header);
    
    // Report header with a create report button
    headers.report =
      $('<div class="report" style="display:none"><span class="title"></span><span class="buttons">' +
        '<button type="button" class="run">Create Report</button>' +
        '</span></div>').appendTo(header);
    headers.report.find('button').button();

    // A header with Save & Cancel buttons
    headers.edit =
      $('<div class="edit" style="display:none"><span class="title"></span><span class="buttons">' +
        '<button type="button" class="cancel">Cancel</button>' +
        '<button type="button" class="save">Save</button>' +
        '</span></div>').appendTo(header);
    headers.edit.find('button').button();
    
    // The special "loader" header, which is actually an overlay used by all header types
    headers.loader =
      $('<div class="loader" style="display:none"><div class="loading"></div></div>').appendTo(header);
    
    // Start out with a standard, no-title header
    Header.switch('standard');
    
    init = true;
    return Header;
  };
  
  /**
   * define(name, html)
   *
   * Allows controllers to define their own header styles by passing in a
   * name and a block of HTML. If the given name is already taken, it will be
   * overwritten with the new definition.
   *
   * Note that the given html should contain only the "inside" of the header,
   * and not the outer <div>. Usually, this will include a "title" span and
   * then whatever custom elements you require.
   */
  Header.define = function(name, html) {
    var old = headers[name];
    
    if (old) {
      headers[name] = null;
      old.remove();
    }
    
    headers[name] = $('<div class="' + name + '" style="display:none">' + html + '</div>').appendTo(header);
    headers[name].find('button').button();
    
    if (current && current == old) {
      Header.switch(name);
    }
    
    return Header;
  };
  
  /**
   * switch(type)
   * switch(type, options)
   *
   * Switch the frame header to the specified type. If provided, the options
   * hash can contain additional options (some are applicable to only certain
   * headers):
   *  title:  a string to display in the header
   *  save:   a callback function for the Save button
   *  cancel: a callback function for the Cancel button
   *  run:    a callback function for the Create Report button
   *  *:      specify custom callbacks for each button class in your header
   */
  Header.switch = function(type, options) {
    var newHeader = headers[type],
        opt,
        button;
    
    if (newHeader) {
      if (options) {
        for(opt in options) {
          if (opt == 'title') {
            // If provided, configure the new title
            
            newHeader.find('span.title').text(options.title);
          } else if ($.isFunction(options[opt])) {
            // If provided, set callbacks for each given button class
            
            button = newHeader.find('button.' + opt);
            
            if (button.length > 0) {
              button.unbind('.frame_header')
                    .bind('click.frame_header', options[opt]);
            }
          }
        }
      }
      
      if (current) {
        current.hide(400);
      }
      
      current = newHeader.show(400);
    }
    
    return Header;
  };
  
  /**
   * standard(title)
   *
   * A simple shortcut for standard headers. Instead of the normal call:
   *
   *   Header.switch('standard', {title: 'My Page'});
   * 
   * A controller can use the following (shortened) function call:
   *
   *   Header.standard('My Page');
   */
  Header.standard = function(title) {
    return Header.switch('standard', {title: title});
  };
  
  /**
   * edit(title, save, cancel)
   *
   * A simple shortcut for edit headers. Instead of the normal call:
   *
   *  Header.switch('edit', {title: 'Edit', save: func1, cancel: func2});
   *
   * A controller can use the following (shortened) function call:
   *
   *  Header.edit('Edit', func1, func2);
   */
  Header.edit = function(title, save, cancel) {
    return Header.switch('edit', {
      title: title,
      save: save,
      cancel: cancel
    });
  };
    
  /**
   * loading(boolean)
   *
   * Show or hide the loading pane that covers ("darkens") the header, along
   * with the loading gif.
   */
  Header.loading = function(bool) {
    if (bool) {
      headers.loader.css('opacity', 0).show()
                    .animate({opacity: 0.3}, {duration: 1500});
      header.find('button').hide();
    } else {
      headers.loader.stop(true).hide();
      header.find('button').show();
    }
    
    return Header;
  };
  
  return Header;
}(Fleet.Frame.Header || {}, Fleet, jQuery));
