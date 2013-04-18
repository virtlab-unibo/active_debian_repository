module ActiveDebianRepository
class Parser
  # ActiveDebianRepository::Parser.new('/home/tmp/Packages')
  def initialize(filename)
    @filename = filename
    @file = File.open(@filename)
    @line_regexp = Regexp.new('^(\S+): (.*)')
  end

  # fast version with grep e sed
  # ["2vcard!0.5-3", .... ]
  # FIXME: We should remove this.
  #
  # * *Args*    :
  # * *Returns* :
  #   - Array
  # * *Raises* :
  #
  def read_unique_id
    res = Array.new
    name = nil
    Kernel.open("|grep '^Package: \\|^Version\: ' #{@filename} | sed -e 's/Package: \\|Version: //'").each do |line|
      if name
        res << "#{name}!#{line.chomp}"
        name = nil
      else
        name = line.chomp
      end
    end
    res
  end

  #
  # * *Args*    :
  # * *Returns* :
  #   - 
  # * *Raises* :
  #
  def each
    res = Hash.new {|h, k| h[k] = ''}
    @file.each do |line|
      if line.chomp.empty?
        yield(res)
        res = Hash.new {|h, k| h[k] = ''}
      else
        if m = @line_regexp.match(line)
          res[m[1].downcase] = m[2]
        else 
          res["body"] += line.gsub(/^\./, '').gsub(/^ /, '')
        end
      end
    end
  ensure
    @file.close
  end

  # gives the attributes in hash for db.
  # in Packages for example there is package attribute that becomes name in database
  #
  # * *Args*    :
  # * *Returns* :
  #   - 
  # * *Raises* :
  #
  def self.db_attributes(p)
    {:name        => p["package"],
     :short_description => p["description"],
     :depends     => p["depends"],
     :version     => p["version"],
     :long_description        => p["body"]}
  end
end
end
