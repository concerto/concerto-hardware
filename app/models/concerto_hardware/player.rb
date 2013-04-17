module ConcertoHardware
  class Player < ActiveRecord::Base
    belongs_to :screen

    validates_associated :screen
  end # class Player
end # module ConcertoHardware
