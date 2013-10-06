module ConcertoHardware
  # The enigne's Ability class simply extends the existing Ability
  # class for the application. We rely on the fact that it already
  # includes CanCan::Ability.
  class Ability < ::Ability
    def initialize(accessor)
      super # Get the main application's rules
      # The main app will delegate to user_abilities, etc.
      # Note the inherited rules give Admins rights to manage everything
    end

    def user_abilities(user)
      super # Get the user rules from the main applications

      # For debugging you may want to make all Players readable
      # can :read, Player

      # Let's defer to Concerto's rules for Screen Permissions.
      # This will apply to both users browsing the hardware info
      # as well as public screens in public instances accessing their data.
      #  - Right now, only admins can create players (TODO)
      #  - It may become desirable in the future for reading to be
      #    restricted or curtailed if a lot of sensitive data is stored here.
      can :read, Player do |player|
        !player.screen.nil? and can? :read, player.screen
      end
      can :update, Player do |player|
        !player.screen.nil? and can? :update, player.screen
      end
      can :delete, Player do |player|
        !player.screen.nil? and can? :delete, player.screen
      end
    end # user_abilities

    def screen_abilities(screen)
      # A logged-in screen can read its own Player information.
      can :read, Player, :screen_id => screen.id
      # In the future it may also need to write reporting data, so
      # this will need to be expanded.
    end # screen_abilities
  end # class Ability
end # module ConcertoHardware
