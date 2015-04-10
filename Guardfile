notification :terminal_notifier, subtitle: 'Yuyi'

guard :bundler do
  watch('Gemfile')
end

guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/lib/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }
end
