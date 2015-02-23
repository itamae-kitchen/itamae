require 'pathname'
included_flag_file = Pathname.new("/tmp/included_rb_is_included")
if included_flag_file.exist? && included_flag_file.read == $$.to_s
  raise "included.rb should not be included twice."
else
  included_flag_file.write($$.to_s)
end

execute "touch /tmp/included_recipe"
