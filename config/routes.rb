# The routing is configured such that it does its own routing.
# This means the central application will specifically mount
# the engine to make the routes available in a certain sub-url,
# for example one route would look like
#    /hardware/players/new
ConcertoHardware::Engine.routes.draw do
  # Just a test welcome page, we'll replace this with something
  # more useful later.
  root :to => proc { |env| [200, {}, ["Welcome to the hardware plugin!"]] }

  # Since we have an isolated namespace, routes are automaticaly scoped
  # to the ConcertoHardware module.
  resources :players do
    collection do
      # Look up a player based on the screen ID.
      match 'by_screen/:screen_id' => ConcertoHardware::PlayersController.action(:show)

      # Show the player associated with the logged in screen.
      # Not implemented yet.
      match 'current' => ConcertoHardware::PlayersController.action(:show)
    end
  end
end
