module ConcertoHardware
  class Engine < ::Rails::Engine
    # Isolated Namespace enforces healthy separation from the Concerto app.
    # Nothing else should come before this call in this class.
    isolate_namespace ConcertoHardware

    # The engine name will be the name of the class
    # that contains the URL helpers for our routes.
    # This must come after isolate_namespace!
    engine_name 'hardware'

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
                   :category => "System",
                   :seq_no => 999,
                   :description => "Client hardware polling interval in seconds")

        # Some code to run at app boot
        init do
          Rails.logger.info "ConcertoHardware: Initialization code is running"
        end

        # The following hooks allow integration into the main Concerto app
        # at the controller and view levels.

        add_header_tags do
          javascript_include_tag "concerto_hardware/application"
        end

        add_controller_hook "ScreensController", :show, :before do
          @player = Player.find_by_screen_id(@screen.id)
        end

        add_controller_hook "ScreensController", :change, :before do
          Rails.logger.info "concerto-hardware: screen change callback"
          if @screen.auth_in_progress? # have a temp token to look at
            if Player.where(:screen_id => @screen.id).count == 0 # No existing player
              if ((@screen.temp_token.length > Screen::TEMP_TOKEN_LENGTH) and
                  (@screen.temp_token[Screen::TEMP_TOKEN_LENGTH].downcase == "s"))
                # Okay, we have a legit player situation.
                Rails.logger.info "concerto-hardware: creating Player for the new Screen!"
                flash[:notice] ||= ""
                player = Player.new
                player.screen_id = @screen.id
                player.activated = true
                if player.save
                  Rails.logger.info "   Success!"
                  #flash[:notice] << " A player hardware profile was automatically created!"
                  # TODO: User notification.
                else
                  Rails.logger.info "   Failed."
                  #flash[:notice] << " We could not create a player hardware profile, however."
                end
              end
            end
          end
        end

        add_view_hook "ScreensController", :screen_details, :partial => "concerto_hardware/screens/screen_link"
      end
    end
  end # class Engine
end # module ConcertoHardware
