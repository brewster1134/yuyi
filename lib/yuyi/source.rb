require 'open-uri'
require 'open3'
require 'pathname'
require 'tmpdir'

class Yuyi::Source

  def available_rolls; @available_rolls end

private

  def self.create_main_tmp_dir
    @@root_tmp_dir = Dir.mktmpdir
    $: << @@root_tmp_dir
  end

  def initialize name, url
    @available_rolls = {}
    @name = name
    @url = url

    create_tmp_dir
    download_source
    get_available_rolls
  end

  def create_tmp_dir
    @tmp_dir = FileUtils.mkdir_p File.join(@@root_tmp_dir, @name.to_s)
  end

  def download_source
    if File.directory? @url
      FileUtils.cp_r @url, @tmp_dir
    else
      zip_file = File.join(@tmp_dir, @name.to_s)

      # Download the file and save it to the tmp directory
      open zip_file, 'w' do |save_file|
        begin
          save_file << open(@url).read
        rescue
          Yuyi.say "Could not open the `#{@name}` source.  Please check that the path is correct.", :type => :fail
          Yuyi.say "If you continue to have issues, your source server may be down.", :type => :warn
          return
        end
      end

      unzip_source zip_file
    end
  end

  def unzip_source file
    # unzip file
    unzip = Yuyi.run "/usr/bin/tar -xf #{file} -C #{@tmp_dir}"
    if unzip == false
      Yuyi.say "The `#{@name}` source is an unrecognized archive format.", :type => :fail
      Yuyi.say "Make sure it is a format supported by tar (tar, pax, cpio, zip, jar, ar, or ISO 9660 image)", :type => :warn
      exit
    end
  end

  # Get source rolls from tmp directory
  #
  def get_available_rolls
    Dir.glob(File.join(@tmp_dir, '**/*.rb')).map do |r|
      name = File.basename(r, '.rb').to_sym
      tmp_path = Pathname.new @@root_tmp_dir
      full_path = Pathname.new r
      require_path = full_path.relative_path_from(tmp_path).to_s.chomp('.rb')

      @available_rolls[name] = {
        :require_path => require_path
      }
    end
  end

  # Run when class is loaded
  create_main_tmp_dir
end
