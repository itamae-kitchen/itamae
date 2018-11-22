define :definition_example, key: 'default' do
  execute "echo 'name:#{params[:name]},key:#{params[:key]},message:#{node[:message]}' > /tmp/created_by_definition"

  remote_file "/tmp/remote_file_in_definition"
end

define :definition_example_2, key: 'default' do
  execute "echo 'name:#{params[:name]},key:#{params[:key]},message:#{node[:message]}' > /tmp/created_by_definition_2_#{params[:name]}"

  remote_file "/tmp/remote_file_in_definition_2_#{params[:name]}" do
    source "files/remote_file_in_definition_2"
  end
end

define :definition_example_3, key: 'default' do
  execute "echo 'name:#{params[:name]},key:#{params[:key]},message:#{node[:message]}' > /tmp/created_by_definition_3_#{params[:name]}"

  remote_file "/tmp/remote_file_in_definition_3_#{params[:name]}" do
    source "files/remote_file_in_definition_3"
  end
end
