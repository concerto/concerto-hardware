require "lib/concerto/plugin_library"

module ConcertoHardware
  class Engine < ::Rails::Engine
    # The engine name will be the name of the class
    # that contains the URL helpers for our routes.
    engine_name 'hardware'

    isolate_namespace ConcertoHardware
    
    include Concerto::PluginLibrary::ClassMethods

    add_controller_hook "ScreensController", :show, :before do
      logger.info "ConcertoPlugin chook eval"
      @player = Player.find_by_screen_id(@screen.id)
    end

    add_view_hook "ScreensController", :screen_details, :partial => "concerto_hardware/screens/screen_link"
    add_view_hook "ScreensController", :screen_details, :text => "<p><b>All systems:</b> go</p>"
    add_view_hook "ScreensController", :fake_hook, :text => "<p><b>All systems:</b> FAIL</p>"
    add_view_hook "ScreensController", :screen_details do
       "<p><b>Name via View Hook:</b> "+@screen.name+"</p>"
    end
  end

  # This method will be called by the ConcertoPlugin module in
  # the main Concerto app on boot if ConcertoHardware is enabled.
  # Plugin parameter is a ConcertoPlugin object, which provides
  # various methods for intialization.
  def self.initialize_plugin(plugin)
    logger = ActiveRecord::Base.logger
    logger.info "Concerto Hardware Plugin Initializing!"

    # Step 1: Register Configuration Items
    plugin.make_plugin_config("poll_interval", "60", 
			      :value_type => "integer",
			      :description => "Client polling interval in seconds")
    # Step 2: Register Routes
    plugin.request_route("hardware", ConcertoHardware::Engine)
  end
end
