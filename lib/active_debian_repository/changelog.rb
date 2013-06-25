module ActiveDebianRepository
  module Changelog 


    def acts_as_debian_changelog
    
      class_attribute :default_values

      self.default_values = {
        :version        => "1.0",
        :date           => "Thu, 1 01 1972 00:00:00 +0200",
        :distributions  => "unstable",
        :urgency        => "low", # low, medium, high, emergency
        :description    => "No description provided"
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

      #      package (version) distribution(s); urgency=urgency
      #         [optional blank line(s), stripped]
      #      * change details
      #        more change details
      #         [blank line(s), included in output of dpkg-parsechangelog]
      #      * even more change details
      #         [optional blank line(s), stripped]
      #      -- maintainer name <email address>[two spaces] date
      #      
      #     date ->  dd month yyyy hh:mm:ss +zzzz
      #     distribution(s) lists the distributions where this version should be
      #     FIXME: every line of the changes section has to be indented by 2 spaces at least.
      def to_s
        %Q[#{package.name} (#{self.version}) #{self.distributions}; urgency=#{self.urgency}

#{self.change_lines}

 -- #{package.maintainer} <#{package.email}>  #{self.date}]
      end 

      #
      #
      def change_lines
        ch_lines = ""
        self.description.each_line do |line| 
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
          if default_attributes.has_key? method_name # check if we have a default value
            return self.default_attributes[method_name]
          else
            raise NoMethodError # nothing can be done, we give up
          end 
        end 
      end

    end
  end
end
