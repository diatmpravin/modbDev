function showRegionSelector() {
  var val = jQuery("#subscription_country :selected").val();
  if (val == "US") {
    jQuery("#us_states").show();
    jQuery("#ca_provinces").hide();
    jQuery("#other_regions").hide();
  } else if (val == "CA") {
    jQuery("#ca_provinces").show();
    jQuery("#us_states").hide();
    jQuery("#other_regions").hide();
  } else {
    jQuery("#other_regions").show();
    jQuery("#us_states").hide();
    jQuery("#ca_provinces").hide();
  }
}

function submitForm() {
  jQuery("#waiting").show();
  jQuery("#submit").hide();
  document.forms[0].submit();
}

jQuery(function() {
  jQuery("#subscription_country").change(showRegionSelector).blur(showRegionSelector);
});
