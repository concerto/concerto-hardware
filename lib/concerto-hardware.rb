module ConcertoHardware
  class Engine < Rails::Engine
    # The engine name will be the name of the class
    # that contains the URL helpers for our routes.
    engine_name 'hardware'

    #isolate_namespace ConcertoHardware
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

    # Step 3: Register Callbacks
    #   (coming soon)
  end

  # Playing around with this idea...
  def self.install_plugin
  end
end
