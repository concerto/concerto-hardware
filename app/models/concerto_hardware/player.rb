module ConcertoHardware
  class Player < ActiveRecord::Base
    belongs_to :screen

    def self.time_accessor(*syms)
      syms.each do |sym|
        attr_accessor sym
        composed_of sym,
              :class_name => 'Time',
              :mapping => [sym.to_s, "to_s"],
              :constructor => Proc.new{ |item| item },
              :converter => Proc.new{ |item| item }
      end
    end

    # Hack to get the multiparameter virtual attributes working
    def self.create_time_zone_conversion_attribute?(name, column)
      column.nil? ? true : super
    end

    validates_associated :screen
    validates_presence_of :screen_id
    validates_presence_of :screen, :message => 'must exist'
    validates_uniqueness_of :screen_id

    time_accessor :wkday_on_time, :wkday_off_time
    time_accessor :wknd_on_time, :wknd_off_time
    time_accessor :party_time
    attr_accessor :wknd_disable
    attr_accessor :force_off

    after_initialize :default_values
    after_find :retrieve_screen_on_off
    before_save :process_screen_on_off

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
    # TODO: Validation
    # TODO: TIMEZONES
    def process_screen_on_off
      ruleset = []
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
          :action => self.wknd_disable=="1" ? "off" : "on",
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
      elsif !screen_on_off_valid
        rules << "On/off rules are invalid. Edit and save the Player to fix."
      else
        rules << "Weekdays: on at "+fmt_time(wkday_on_time, "%l:%M%P")+", "+
          "off at "+fmt_time(wkday_off_time, "%l:%M%P")+"."
        if wknd_disable
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
        timeobj.strftime(fmt)
      end
    end

  end # class Player
end # module ConcertoHardware
