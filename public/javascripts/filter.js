/**
 * Filter.js
 * Hooks and handling of the Filter form
 */
Filter = {

  init: function() {
    q("#query").focus(Filter.showDetails);
    q("#query").blur(Filter.parseQuery);

    q("#filterDetails").css("width", q("#filter").css("width"));
    q("#filterDetails").keypress(function(event) {
      // Capture ENTER and submit tag
      if (event.which == 13) {
        Filter.populateAndSubmit();
      }
    });

    q("input[type=text]", "#filterDetails").blur(Filter.populateQuery);

    q("input[type=button]", "#filterDetails").click(Filter.populateAndSubmit);
    q("a", "#filterDetails").click(Filter.hideDetails);

    q("#filter_clear").click(Filter.clearQuery);

    Filter.clearDetails();
    Filter.parseQuery();
  }
  ,
  clearQuery: function() {
    q(this).parents("form").
      append("<input type='hidden' name='_method' value='DELETE'/>").
      submit();

    return false;
  }
  ,
  /**
   * Ensure that the detail search form is never showing
   * old or invalid information.
   */
  clearDetails: function() {
    q("input[type=text]", "#filterDetails").each(function(index, field) {
      q(field).val("");
    });
  }
  ,
  /**
   * Show the filter details box
   */
  showDetails: function() {
    q("#filterDetails").slideDown('slow');
  }
  ,
  /**
   * Hide the filter details box
   */
  hideDetails: function() {
    q("#filterDetails").slideUp('slow');
  }
  ,
  /**
   * Take what's in the details Form, make sure it's been populated
   * into #query, then submit the form
   */
  populateAndSubmit: function() {
    Filter.populateQuery();
    Filter.hideDetails();
    q("form", "#filter").submit();
  }
  ,
  /**
   * If a query exists in the field, we need to parse it out
   * and fill the appropriate fields in the form.
   */
  parseQuery: function() {
    var query = q("#query").val();

    if(query == "") { return; }

    var parts = query.split(/\s/),
        found, key, values = {},
        details = q("#filterDetails");

    q.each(parts, function(index, word) {
      if(found = word.match(/(.*):$/)) {
        key = found[1];
        values[key] = [];
      } else {
        values[key].push(word);
      }
    });

    q.each(values, function(key, values) {
      details.find("#" + key).val(values.join(" "));
    });
  }
  ,
  /**
   * As people type in values into individual search fields, make sure
   * the query box itself gets updated with the proper search terms
   */
  populateQuery: function() {
    var queryBox = q("#query"), query = [];

    q("input[type=text]", "#filterDetails").each(function(index, field) {
      if(q(field).val() != "") {
        query.push(q(field).attr("name") + ":");
        query.push(q(field).val());
      }
    });

    queryBox.val(query.join(" "));
  }

}

jQuery(function() {
  Filter.init();
});

