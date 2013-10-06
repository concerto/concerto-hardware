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

      # Mimic the screen permissions - if you can manage the screen,
      # you can view and manage the associated player.
      can [:read, :update, :delete], Player do |player|
        (not player.screen.nil?) && (owner=player.screen.owner) &&
        (
          (owner.is_a?(User) && owner == user) ||
          (owner.is_a?(Group) && 
           (owner.leaders.include?(user)  ) ||
            owner.user_has_permissions?(user, :regular, :screen,[:all])
          )
        )
      end

    end # user_abilities

    def screen_abilities(screen)
      can :read, Player, :screen_id => screen.id
      # TODO: This doesn't account for public screens etc.
      #    1. can we use public screens?
      #    2. It would be better to directly mimic Screen permissions.
      #           something like do |pscreen| {can? :read, pscreen} perhaps?
    end # screen_abilities
  end # class Ability
end # module ConcertoHardware
