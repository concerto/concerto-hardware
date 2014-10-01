module ConcertoHardware
  # Provides the time_accessor method, which is useful for creating a
  # virtual parameter of type Time. The time is read and written as a
  # standard Time-parasable string, which makes it possible to have form
  # fields that reference the virtual attribute directly.
  #
  # Note that it is possible to set as a Time object (to save instantiations).
  # You cannot read the Time object directly, however.
  #
  # Example
  #
  #   class MyModel
  #     extend ConcertoHardware::TimeAccessible
  #     time_accessor :party_time
  #
  #     def is_it_party_time?
  #       Time.now > Time.new(self.party_time || "9001")
  #     end
  #   end
  #
  #   inst = MyModel.new
  #   inst.party_time = "2011-11-11 11:11:11 -0000"
  #   inst.party_time # => "2011-11-11 11:11:11 -0000"
  #
  #   inst.party_time = Time.now + 24*60*60 # the party is tommorrow
  #   inst.party_time # => "2014-10-01 23:01:06 -0400"
  #
  module TimeAccessible
    def time_accessor(*syms)
      syms.each do |sym|
       self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{sym}
            if @#{sym}_timeobj.is_a? Time
              @#{sym}_timeobj.to_s
            else
              nil
            end
          end
          def #{sym}=(val)
            if val.is_a? Time
              @#{sym}_timeobj = val
            elsif val.is_a? String
              @#{sym}_timeobj = Time.parse(val)
            else
              raise ArgumentError.new("Only Strings or Times allowed")
            end
          end
        RUBY
      end
    end
  end # TimeAccessible
end # ConcertoHardware
