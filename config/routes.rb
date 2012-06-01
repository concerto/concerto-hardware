# Note: currently, this goes directly into the app, so the
# route from root is just /players. Eventually, we may want
# to create the route against the engine, and then just mount
# the engine from the main app. Or, we could put it in a namespace.

Rails.application.routes.draw do
  scope :module => "ConcertoHardware" do
    resources :players
   end
end
