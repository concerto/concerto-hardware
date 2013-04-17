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

      # For now lets make all Players readable
      can :read, Player

      # Mimic the screen permissions - if you can manage the screen,
      # you can view and manage the associated player.
      can [:read, :update, :delete], Player do |player|
        (not player.screen.nil?) && (owner=player.screen.owner) &&
        (
          (owner.is_a?(User) && owner == user) ||
          (owner.is_a?(Group) && 
           (owner.leaders.include?(user)  ) ||
            owner.user_has_permissions?(user, :regular, :screen,[:all]))
          )
        )
      end

    end

  end # class Ability
end # module ConcertoHardware
