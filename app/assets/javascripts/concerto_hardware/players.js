// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in plugin.js

// Namespace the plugin for neatness
var ConcertoHardware = {
  _initialized: false,

  updateWkndOnOff: function() {
    if ($('#player_wknd_disable').is(':checked')) {
      $('#wknd_on_time_div').hide();
      $('#wknd_off_time_div').hide();
    } else {
      $('#wknd_on_time_div').show();
      $('#wknd_off_time_div').show();
    }
  },
  updateAlwaysOn: function() {
    show = !$('#player_always_on').is(':checked');
    $('#on_off_details_div').toggle(show);
  },

  initPlayers: function() {
    ConcertoHardware.updateWkndOnOff();
    ConcertoHardware.updateAlwaysOn();

    if (ConcertoHardware._initialized) {
      // console.debug('ConcertoHardware already initialized');
    } else {
      // console.debug('ConcertoHardware initializing');
      $(document).on('change', '#player_wknd_disable', ConcertoHardware.updateWkndOnOff);
      $(document).on('change', '#player_always_on', ConcertoHardware.updateAlwaysOn);
      ConcertoHardware._initialized = true;
    }
  }
};

$(document).ready(ConcertoHardware.initPlayers);
$(document).on('turbolinks:load', ConcertoHardware.initPlayers);
