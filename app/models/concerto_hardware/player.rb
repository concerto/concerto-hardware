require 'concerto_hardware/time_accessible'

module ConcertoHardware
  class Player < ActiveRecord::Base
    # Get the time_accessor method for virtual Time attributes
    extend ConcertoHardware::TimeAccessible

    # Virtual attributes (these are read from and written to the database
    # as parts of serialized JSON fields such as screen_on_off)
    time_accessor :wkday_on_time, :wkday_off_time
    time_accessor :wknd_on_time, :wknd_off_time
    attr_accessor :always_on
    attr_accessor :wknd_disable
    attr_accessor :force_off

    belongs_to :screen

    # Hack to get the multiparameter virtual attributes working
    def self.create_time_zone_conversion_attribute?(name, column)
      column.nil? ? true : super
    end

    validates_associated :screen
    validates_presence_of :screen_id
    validates_presence_of :screen, :message => 'must exist'
    validates_uniqueness_of :screen_id

    # Time virtual attributes return nil if an invalid attribute
    # was given.
    validates :wkday_on_time, :wkday_off_time, :presence => {
      :message => :must_be_valid_time
    }
    validates :wknd_on_time, :wknd_off_time, :presence => {
      :unless => "wknd_disable?",
      :message => :must_be_valid_time
    }
    validate :on_must_come_before_off

    after_initialize :default_values
    after_find :retrieve_screen_on_off
    before_save :process_screen_on_off

    # Evaluates truthiness of the virtual attribute.
    def wknd_disable?
      return true if self.wknd_disable == "1"
      return true if self.wknd_disable == true
      return false
    end

    def default_values
      self.screen_on_off ||= [
        {
          :action => "on",
          :wkday => "12345", # M-F
          :time_after => "07:00",
          :time_before => "20:00"
        },
        {
          :action => "on",
          :wkday => "06", # Sun, Sat
          :time_after => "09:00",
          :time_before => "20:00"
        }
      ].to_json
      retrieve_screen_on_off #populate the virtual attributes.
    end

    # Take screen controls from the form and store them
    # in a standard format that the player will understand.
    # https://github.com/concerto/concerto-hardware/
    #                            wiki/Player-API#screen-onoff-times
    # TODO: Formatting for datetimes
    # TODO: TIMEZONES
    def process_screen_on_off
      ruleset = []
      if wknd_disable?
        # Special case: we can ignore invlaid wknd times if we're off
        # on the weekend (avoids a rough edge on form submission).
        self.wknd_on_time = "09:00" if wknd_on_time.nil?
        self.wknd_off_time = "23:00" if wknd_off_time.nil?
      end
      unless self.wkday_on_time.nil? or self.wkday_off_time.nil?
        ruleset << {
          :action => "on",
          :wkday => "12345", # M-F
          :time_after => fmt_time(wkday_on_time),   # "07:00"
          :time_before => fmt_time(wkday_off_time), # "23:00"
        }
      end
      unless self.wknd_on_time.nil? or self.wknd_off_time.nil?
        ruleset << {
          :action => self.wknd_disable? ? "off" : "on",
          :wkday => "06", # Sun, Sat
          :time_after => fmt_time(wknd_on_time),  # "07:00"
          :time_before => fmt_time(wknd_off_time), # "23:00"
        }
      end
      if self.force_off == "1"
        ruleset << {
          :action => "off",
          :date => Time.now.strftime("%Y-%m-%d")
        }
      end
      if self.always_on == "1"
        # Note: supersedes everything else.
        ruleset << {
          :action => "force_on"
        }
      end
      if ruleset.empty? && self.screen_on_off.blank?
        ruleset << {
          :action => "on"
        }
      end

      self.screen_on_off = ruleset.to_json unless ruleset.empty?
    end

    # This is a very limited parsing of the on/off rules
    # Pretty much it will only work on rulesets created by the methods
    # in this model. The format is very flexible, but this model only
    # supports 3 simple rules.
    def retrieve_screen_on_off
      return nil if screen_on_off.blank?
      self.always_on = false # default unless rule exists

      ruleset = ActiveSupport::JSON.decode(self.screen_on_off)
      ruleset.each do |rule|
        if rule.has_key? 'action'
          if rule.has_key? 'wkday' and rule['wkday']=='12345' and 
            rule['action']='on'
            if rule.has_key? 'time_after' and rule.has_key? 'time_before'
              self.wkday_on_time = Time.parse(rule['time_after'])
              self.wkday_off_time = Time.parse(rule['time_before'])
            end
          end # weekday
          if rule.has_key? 'wkday' and rule['wkday']=='06' 
            if rule.has_key? 'time_after' and rule.has_key? 'time_before'
              self.wknd_on_time = Time.parse(rule['time_after'])
              self.wknd_off_time = Time.parse(rule['time_before'])
            end
            self.wknd_disable = (rule['action'] != 'on')
          end # weekend
          if rule.has_key? 'date'
            if rule['date'] == Time.now.strftime("%Y-%m-%d")
              self.force_off = (rule['action'] != 'on')
            end
          end # force off rules
          if rule['action'] == 'force_on'
            self.always_on = true
          end # always on
        end # has an action
      end # each rule
    end # retrive_screen_on_off

    # Relies on retrive_screen_on_off having been called at load.
    def screen_on_off_valid
      !(
        wkday_on_time.nil? or  wkday_off_time.nil? or
        wknd_on_time.nil? or wknd_off_time.nil? or wknd_disable.nil?
      )
    end

    # Returns an array of strings describing the screen's behavior.
    # Relies on retrive_screen_on_off having been called at load.
    def describe_screen_on_off
      rules = []
      if self.screen_on_off.blank?
        rules << "On/off times not configured. The screen will always be on."
      elsif self.always_on
        rules << "Screen is always on. Click 'Edit Player' to configure "+
                 "power-saving screen controls."
      elsif !screen_on_off_valid
        rules << "On/off rules are invalid. Edit and save the Player to fix."
      else
        rules << "Weekdays: on at "+fmt_time(wkday_on_time, "%l:%M%P")+", "+
          "off at "+fmt_time(wkday_off_time, "%l:%M%P")+"."
        if wknd_disable?
          rules << "Weekends: off."
        else
          rules << "Weekends: on at "+fmt_time(wknd_on_time, "%l:%M%P")+", "+
            "off at "+fmt_time(wknd_off_time, "%l:%M%P")+"."
        end
        if force_off
          rules << "Manual override: screen will be off until midnight tonight."
        end
      end
      rules
    end

    def fmt_time(timeobj, fmt = "%H:%M")
      if !timeobj.nil?
        if timeobj.is_a?(String)
          timeobj = Time.parse(timeobj)
        end
        timeobj.strftime(fmt).strip
      end
    end

    def polling_interval
      return ConcertoConfig[:poll_interval].to_i
    end

    # Get the timezone that has been configured for this screen,
    # using in the standard region/city format.
    # Example: "America/New York"
    # This is used in the Player API for Bandshell.
    def time_zone
      # The concerto config and screen config are stored in
      # ActiveSupport::TimeZone's "friendly" time zone format:
      #   "Eastern Time (US & Canada)"
      if screen.nil? or screen.time_zone.nil?
        pretty_time_zone = ConcertoConfig[:system_time_zone]
      else
        pretty_time_zone = screen.time_zone
      end
      # Now just backtrack to the canonical name which will
      # be useful to the players.
      ActiveSupport::TimeZone::MAPPING[pretty_time_zone]
    end

    def as_json(options)
      json = super(options)
      json["screen_on_off"] = ActiveSupport::JSON.decode(self.screen_on_off)
      json["polling_interval"] = self.polling_interval
      json
    end

    private

    # Time order validation method
    def on_must_come_before_off
      unless wkday_off_time.nil? or wkday_on_time.nil?
        if wkday_off_time < wkday_on_time
          errors.add :wkday_off_time, :must_come_after,
            :before => self.class.human_attribute_name(:wkday_on_time)
        end
      end
      unless wknd_off_time.nil? or wknd_on_time.nil? or wknd_disable?
        if wknd_off_time < wknd_on_time
          errors.add :wknd_off_time, :must_come_after,
            :before => self.class.human_attribute_name(:wknd_on_time)
        end
      end
    end
  end # class Player
end # module ConcertoHardware
