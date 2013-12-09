require 'fileutils'

class Xcode < Yuyi::Roll
  available_options(
    :apple_id => {
      :description => 'Your Apple ID username',
      :example => 'john@mac.com',
      :required => true
    },
    :apple_password => {
      :description => 'Your Apple ID password',
      :example => 'foobar123',
      :required => true
    }
  )

  install do
    # https://gist.github.com/trinitronx/6237049

    install_dir = "#{ENV['TMPDIR']}Xcode"
    FileUtils.rm_rf install_dir
    `git clone https://gist.github.com/6237049.git #{install_dir}`
    script_file = File.join(install_dir, 'Install_XCode.applescript')

    # Replace the credentials in the script
    script = File.read script_file
    script.gsub! /YOUR APPLE ID HERE/, options[:apple_id]
    script.gsub! /YOUR PASSWORD HERE/, options[:apple_password]

    # Re-write the file
    File.open(script_file, 'w') { |f| f.write script }

    # Run the script
    Dir.chdir install_dir
    `osascript Install_XCode.applescript`
  end

  installed? do
    command? 'xcode-select'
  end
end
