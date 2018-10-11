# https://www.debian.org/doc/manuals/maint-guide/dreq.en.html#changelog
module ActiveDebianRepository
  module Changelog 

    def acts_as_debian_changelog
      validates :package, presence: true

      class_attribute :default_values

      self.default_values = {
        version:       "1.0",
        date:          "Thu, 1 01 1972 00:00:00 +0200",
        distributions: "unstable",
        urgency:       "low", # low, medium, high, emergency
        description:   "No description provided"
      }

      include InstanceMethods
    end


    # Create a string with the current date
    # compatible and with the same semantics
    # of RFC 2822 and RFC 5322.
    #
    # day-of-week, dd month yyyy hh:mm:ss +zzzz
    def self.date_line
      Time.new.strftime("%a, %d %b %Y %H:%M:%S %z") 
    end

    module InstanceMethods
      #     date ->  dd month yyyy hh:mm:ss +zzzz
      #     distribution(s) lists the distributions where this version should be
      #     FIXME: every line of the changes section has to be indented by 2 spaces at least.
      def to_s
        %Q[#{package.name} (#{self.version || default_values[:version]}) #{self.distributions || default_values[:distributions]}; urgency=#{self.urgency || default_values[:urgency]}

#{self.change_lines}

 -- #{package.maintainer} <#{package.email}>  #{self.date || Changelog.date_line}]
      end 

      # clean description 
      def change_lines
        ch_lines = ""
        (self.description || default_values[:description]).each_line do |line| 
          ch_lines << "  " << line
        end
        ch_lines
      end

      # Return the default value if the method name is a 
      # known changelog property. Raise otherwise.
      def method_missing (method_name, *args, &block)
        begin
          super #let activeBase to work as it wish.
        rescue NoMethodError # if nothing handled it
          if default_values.has_key? method_name # check if we have a default value
            return self.default_values[method_name]
          else
            raise NoMethodError # nothing can be done, we give up
          end 
        end 
      end

    end
  end
end
