module ConcertoHardware
  # Congratulations! You've found this engine's secret sauce.
  # In a regular isolated engine, the engine's ApplicationController
  # inherits from ActionController::Base. We're using the the main app's
  # ApplicationController, making the isolation a little less strict.
  # For example, we get the layout from the main Concerto app.
  # Note that links back to the main application will need to directly
  # reference the main_app router.
  class ApplicationController < ::ApplicationController
  end
end
