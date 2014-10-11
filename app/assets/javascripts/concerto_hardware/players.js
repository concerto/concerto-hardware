// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in plugin.js

// Namespace the plugin for neatness
var ConcertoHardware = {
  updateWkndOnOff: function() {
    if ($('#player_wknd_disable').is(':checked')) {
      $('#wknd_on_time_div').hide();
      $('#wknd_off_time_div').hide();
    } else {
      $('#wknd_on_time_div').show();
      $('#wknd_off_time_div').show();
    }
  },

  initPlayers: function() {
    ConcertoHardware.updateWkndOnOff();
    $('#player_wknd_disable').change(function() {
      ConcertoHardware.updateWkndOnOff();
    });
  }
};

$(document).ready(ConcertoHardware.initPlayers);
$(document).on('page:change', ConcertoHardware.initPlayers);
