package 'sl'

######

gem_package 'ast' do
  version '2.0.0'
  options ['--no-document']
  cwd '/tmp'
end

######

# Docker backend raises an error with `user` option, so it tests only on `itamae local`.
# After fix this error, please move this code and the spec to `default.rb`.
file "/tmp/file_as_ordinary_user" do
  content "Hello World"
  user "itamae"
  owner "itamae"
  group "itamae"
end
