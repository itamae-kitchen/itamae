define :definition_example, key: 'default' do
  execute "echo 'name:#{params[:name]},key:#{params[:key]},message:#{node[:message]}' > /tmp/created_by_definition"

  remote_file "/tmp/remote_file_in_definition"
end

