module ConcertoHardware
  class Engine < ::Rails::Engine
    # The engine name will be the name of the class
    # that contains the URL helpers for our routes.
    #  TODO: This isn't working.
    engine_name 'hardware'

    isolate_namespace ConcertoHardware

    # Define plugin information for the Concerto application to read.
    # Do not modify @plugin_info outside of this static configuration block.
    def plugin_info(plugin_info_class)
      @plugin_info ||= plugin_info_class.new do
        # Make the engine's controller accessible at /hardware
        add_route("hardware", ConcertoHardware::Engine)

        # Initialize configuration settings with a description and a default.
        # Administrators can change the value through the Concerto dashboard.
        add_config("poll_interval", "60", 
                   :value_type => "integer",
                   :description => "Client polling interval in seconds")

        # Some code to run at app boot
        init do
          Rails.logger.info "ConcertoHardware: Initialization code is running"
        end

        # The following hooks allow integration into the main Concerto app
        # at the controller and view levels.

        add_controller_hook "ScreensController", :show, :before do
          @player = Player.find_by_screen_id(@screen.id)
        end

        add_view_hook "ScreensController", :screen_details, :partial => "concerto_hardware/screens/screen_link"
        add_view_hook "ScreensController", :screen_details, :text => "<p><b>All systems:</b> go</p>"
        add_view_hook "ScreensController", :fake_hook, :text => "<p><b>All systems:</b> FAIL</p>"
        add_view_hook "ScreensController", :screen_details do
          "<p><b>Name via View Hook:</b> "+@screen.name+"</p>"
        end
      end
    end
  end # class Engine
end # module ConcertoHardware