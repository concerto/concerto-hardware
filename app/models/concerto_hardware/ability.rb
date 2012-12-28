module ConcertoHardware
  # The enigne's Ability class simply extends the existing Ability
  # class for the application. We rely on the fact that it already
  # includes CanCan::Ability.
  class Ability < ::Ability
    # TODO: Some sensible authentication rules
    def initialize(accessor)
      Rails.logger.info "ConcertoPlugin: ConcertoHardware ability initializing"
      super # Get the main application's rules
      # Note the inherited rules giving Admins rights to manage everything

      # For now lets make all Players readable
      can :read, Player
    end

    # TODO: extend user_abilities(user), etc., directly.

  end # class Ability
end # module ConcertoHardware
