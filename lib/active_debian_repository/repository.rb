module ActiveDebianRepository 
  module Repository

    # Configuration defaults
    @config = {
      :root => "/var/www/repository",
      :pool => "/dist/pool/section",
      :src => true
    }

    @valid_config_keys = @config.keys

    # Configure the module. 
    #
    # * *Args*    :
    #   - +opts+ -> Hash with configuration options.
    # * *Returns* :
    #   -
    # * *Raises* :
    #   - ++ ->
    #
    def self.configure(opts = {})
      opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
    end

    # Create the directory tree of the repository.
    #
    # * *Args*    :
    # * *Returns* :
    #   -
    # * *Raises* :
    #   - ++ ->
    #
    def create

    end

    # Create the directory for the package 
    # in the repository directory tree.
    #
    # * *Args*    :
    #   - +deb_filename+ -> package file name.
    # * *Returns* :
    #   -
    # * *Raises* :
    #   - ++ ->
    #
    def self.mk_dst_dir(deb_filename)
      begin
        full_path = File.join(self.pool_full_path, deb_filename[0])
        FileUtils.mkdir_p(full_path)
      rescue => e
        Logger.new(STDOUT).info("#{e}")
      end
      full_path
    end

    
    # Move a file (debian package) into the proper directory 
    # under the root of the repository.
    #
    # * *Args*    :
    #   - +deb_filename+ -> package file name.
    # * *Returns* :
    #   -
    # * *Raises* :
    #   - ++ ->
    #
    def self.add_package( deb_filename ) 
      res = true
      begin
        #make destination directory for the deb	
        full_path =  mk_dst_dir deb_filename
        #move the deb file into the dest directory
        FileUtils.mv(deb_filename, full_path, :force => true)
      rescue
        logger.info "Failed to move #{deb_filename} in #{full_path}"
        res = false
      end
      res ? File.join(full_path, deb_filename) : false
    end

    def self.root
      @config[:root]
    end

    def self.pool
      @config[:pool]
    end

    def self.pool_full_path
      File.join(self.root, self.pool)
    end

  end
end
