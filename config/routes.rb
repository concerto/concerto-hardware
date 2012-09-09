# The routing is configured such that it does its own routing.
# This means the central application will specifically mount
# the engine to make the routes available in a certain sub-url,
# for example one route would look like
#    /hardware/players/new
ConcertoHardware::Engine.routes.draw do
  # Just a test welcome page, we'll replace this with something
  # more useful later.
  root :to => proc { |env| [200, {}, ["Welcome to the hardware plugin!"]] }

  # The scope just refers to the module where the controller lives
  # and does not affect the routing URL.
  scope :module => "ConcertoHardware" do
   resources :players
  end
end
