require 'open-uri'
require 'pathname'
require 'tmpdir'

class Yuyi::Source
  ROLL_FILE_GLOB = '**/*.rb'

  def available_rolls; @available_rolls end

private

    def self.create_main_tmp_dir
      @@root_tmp_dir = Dir.mktmpdir
      $: << @@root_tmp_dir
    end

    def initialize name, path
      @available_rolls = {}
      @name = name
      @path = path

      create_tmp_dir
      download_source
      get_available_rolls
    end

    def create_tmp_dir
      dir = FileUtils.mkdir_p(File.join(@@root_tmp_dir, @name.to_s))

      # RUBY_VERSION
      # mkdir_p <= 1.8 returns a string
      # mkdir_p >= 1.9 returns an array
      #
      dir = case dir
      when Array
        dir.first
      else
        dir
      end

      @tmp_dir = dir
    end

    def download_source
      # if remote source
      if URI.parse(@path).scheme
        zip_file = File.join(@tmp_dir, @name.to_s)

        # Download the file and save it to the tmp directory
        open zip_file, 'w' do |save_file|
          begin
            save_file << open(@path).read
          rescue
            Yuyi.say "Could not open the `#{@name}` source.  Please check that the path is correct.", :type => :fail
            Yuyi.say "If you continue to have issues, your source server may be down.", :type => :warn
            return
          end
        end

        unzip_source zip_file

      # if local source
      else
        path = File.expand_path(@path)

        # if file, expect archive file and unzip it
        if File.file? path
          unzip_source path if File.file? path

        # if dir, copy rolls out of it
        else
          FileUtils.cp_r Dir.glob(File.join(path, ROLL_FILE_GLOB)), @tmp_dir
        end
      end
    end

    def unzip_source file
      # unzip file
      unzip = if RUBY_PLATFORM =~ /darwin/
        Yuyi.run "tar -xf #{file} -C #{@tmp_dir}", :boolean => true
      else
        Yuyi.run "unzip -o #{file} -d #{@tmp_dir}", :boolean => true
      end

      if unzip == false
        Yuyi.say "The `#{@name}` source is an unrecognized archive format.", :type => :fail
        Yuyi.say "Make sure it is a format supported by tar (tar, pax, cpio, zip, jar, ar, or ISO 9660 image)", :type => :warn
        exit
      end
    end

    # Get source rolls from tmp directory
    #
    def get_available_rolls
      Dir.glob(File.join(@tmp_dir, ROLL_FILE_GLOB)).map do |r|
        name = File.basename(r, '.rb').to_sym
        tmp_path = Pathname.new @@root_tmp_dir
        full_path = Pathname.new r
        require_path = full_path.relative_path_from(tmp_path).to_s.chomp('.rb')

        @available_rolls[name] = require_path
      end
    end

  # Run when class is loaded
  create_main_tmp_dir
end
