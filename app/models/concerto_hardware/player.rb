module ConcertoHardware
  class Player < ActiveRecord::Base
    belongs_to :screen

    validates_associated :screen
    validates_presence_of :screen_id
    validates_presence_of :screen, :message => 'must exist'
    validates_uniqueness_of :screen_id
  end # class Player
end # module ConcertoHardware
