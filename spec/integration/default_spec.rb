require 'spec_helper'

describe user("itamae") do
  it { should exist }
  it { should have_uid 1234 }
  it { should have_home_directory '/home/itamae' }
  it { should have_login_shell '/bin/dash' }
end

describe file('/tmp/included_recipe') do
  it { should be_file }
end

describe package('dstat') do
  it { should be_installed }
end

describe package('sl') do
  it { should be_installed }
end

describe package('resolvconf') do
  it { should_not be_installed }
end

%w!/tmp/remote_file /tmp/remote_file_auto!.each do |f|
  describe file(f) do
    it { should be_file }
    its(:content) { should match(/Hello Itamae/) }
  end
end

describe file('/tmp/directory') do
  it { should be_directory }
  it { should be_mode 700 }
  it { should be_owned_by "itamae" }
  it { should be_grouped_into "itamae" }
end

describe file('/tmp/directory_never_exist1') do
  it { should_not be_directory }
end

%w!/tmp/template /tmp/template_auto!.each do |f|
  describe file(f) do
    it { should be_file }
    its(:content) { should match(/Hello/) }
    its(:content) { should match(/Good bye/) }
    its(:content) { should match(/^total memory: \d+kB$/) }
    its(:content) { should match(/^uninitialized node key: $/) }
  end
end

describe file('/tmp/file') do
  it { should be_file }
  its(:content) { should match(/Hello World/) }
  it { should be_mode 777 }
end

describe file('/tmp/file_with_suid') do
  it { should be_file }
  it { should be_mode 4755 }
  it { should be_owned_by "itamae" }
  it { should be_grouped_into "itamae" }
end

describe file('/tmp/execute') do
  it { should be_file }
  its(:content) { should match(/Hello Execute/) }
end

describe file('/tmp/never_exist1') do
  it { should_not be_file }
end

describe file('/tmp/never_exist2') do
  it { should_not be_file }
end

describe file('/tmp/http_request.html') do
  it { should be_file }
  its(:content) { should match(/"from":\s*"itamae"/) }
end

describe file('/tmp/http_request_delete.html') do
  it { should be_file }
  its(:content) { should match(/"from":\s*"itamae"/) }
end

describe file('/tmp/http_request_post.html') do
  it { should be_file }
  its(:content) { should match(/"from":\s*"itamae"/) }
  its(:content) { should match(/"love":\s*"sushi"/) }
end

describe file('/tmp/http_request_put.html') do
  it { should be_file }
  its(:content) { should match(/"from":\s*"itamae"/) }
  its(:content) { should match(/"love":\s*"sushi"/) }
end

describe file('/tmp/http_request_headers.html') do
  it { should be_file }
  its(:content) { should match(/"User-Agent":\s*"Itamae"/) }
end

describe file('/tmp/http_request_redirect.html') do
  it { should be_file }
  its(:content) { should match(/"from":\s*"itamae"/) }
end

describe file('/tmp/notifies') do
  it { should be_file }
  its(:content) { should eq("2431") }
end

describe file('/tmp/subscribes') do
  it { should be_file }
  its(:content) { should eq("2431") }
end

describe file('/tmp/cron_stopped') do
  it { should be_file }
  its(:content) do
    expect(subject.content.lines.size).to eq 1
  end
end

# FIXME: cron service is not running in docker...
#
# root@3450c6da6ea5:/# ps -C cron
#   PID TTY          TIME CMD
# root@3450c6da6ea5:/# service cron start
# Rather than invoking init scripts through /etc/init.d, use the service(8)
# utility, e.g. service cron start
#
# Since the script you are attempting to invoke has been converted to an
# Upstart job, you may also use the start(8) utility, e.g. start cron
# root@3450c6da6ea5:/# ps -C cron
#   PID TTY          TIME CMD
# root@3450c6da6ea5:/#

# describe file('/tmp/cron_running') do
#   it { should be_file }
#   its(:content) do
#     expect(subject.content.lines.size).to eq 2
#   end
# end

describe file('/tmp-link') do
  it { should be_linked_to '/tmp' }
  its(:content) do
    expect(subject.content.lines.size).to eq 0
  end
end

describe file('/tmp-link-force') do
  it { should be_linked_to '/tmp' }
end

describe file('/tmp/link-force-no-dereference') do
  it { should be_linked_to 'link-force-no-dereference2' }
end

describe file('/tmp/link-force-no-dereference/link-force-no-dereference2') do
  it { should_not exist }
end

describe command('cd /tmp/git_repo && git rev-parse HEAD') do
  its(:stdout) { should match(/3116e170b89dc0f7315b69c1c1e1fd7fab23ac0d/) }
end

describe command('cd /tmp/git_repo_submodule/empty_repo && cat README.md') do
  its(:stdout) { should match(/Empty Repo/) }
end

describe command('cd /tmp/git_repo_depth_1 && git rev-list --count HEAD') do
  its(:stdout) { should eq "1\n" }
end

describe file('/tmp/created_by_itamae_user') do
  it { should be_file }
  it { should be_owned_by 'itamae' }
  its(:content) { should eq("/home/itamae\n/home/itamae") }
end

describe file('/tmp/created_in_default2') do
  it { should be_file }
end

describe file('/tmp/never_exist3') do
  it { should_not be_file }
end

describe file('/tmp/never_exist4') do
  it { should_not be_file }
end

describe file('/tmp/created_in_redefine') do
  it { should be_file }
  its(:content) { should match(/first/) }
end

describe command('gem list') do
  its(:stdout) { should include('tzinfo (1.2.2, 1.1.0)') }
end

describe command('gem list') do
  its(:stdout) { should include('rake (11.1.0)') }
end

describe command('gem list') do
  its(:stdout) { should_not include('test-unit') }
end

describe command('ri Bundler') do
  its(:stderr) { should eq("Nothing known about Bundler\n") }
end

describe file('/tmp/created_by_definition') do
  it { should be_file }
  its(:content) { should eq("name:name,key:value,message:Hello, Itamae\n") }
end

describe file('/tmp/remote_file_in_definition') do
  it { should be_file }
  its(:content) { should eq("definition_example\n") }
end

describe file('/tmp/created_by_definition_2_created') do
  it { should be_file }
  its(:content) { should eq("name:created,key:value2,message:Hello, Itamae\n") }
end

describe file('/tmp/remote_file_in_definition_2_created') do
  it { should be_file }
  its(:content) { should eq("definition_example_2\n") }
end

describe file('/tmp/created_by_definition_2_not_created') do
  it { should_not exist }
end

describe file('/tmp/remote_file_in_definition_2_not_created') do
  it { should_not exist }
end

describe file('/tmp/created_by_definition_3_created') do
  it { should be_file }
  its(:content) { should eq("name:created,key:value3,message:Hello, Itamae\n") }
end

describe file('/tmp/remote_file_in_definition_3_created') do
  it { should be_file }
  its(:content) { should eq("definition_example_3\n") }
end

describe file('/tmp/created_by_definition_3_not_created') do
  it { should_not exist }
end

describe file('/tmp/remote_file_in_definition_3_not_created') do
  it { should_not exist }
end

describe file('/tmp/multi_delayed_notifies') do
  it { should be_file }
  its(:content) { should eq("1\n2\n3\n4\n") }
end

describe file('/tmp/multi_immediately_notifies') do
  it { should be_file }
  its(:content) { should eq("1\n2\n3\n4\n") }
end

describe file('/tmp/file_edit_sample') do
  it { should be_file }
  its(:content) { should eq("Hello, Itamae") }
  it { should be_mode 400 }
  it { should be_owned_by "itamae2" }
  it { should be_grouped_into "itamae2" }
end

describe file('/tmp/file_edit_with_suid') do
  it { should be_file }
  it { should be_mode 4755 }
  it { should be_owned_by "itamae2" }
  it { should be_grouped_into "itamae2" }
end

describe file('/tmp/file_edit_keeping_mode_owner') do
  it { should be_file }
  its(:content) { should eq("Hello, Itamae") }
  it { should be_mode 444 }
  it { should be_owned_by "itamae" }
  it { should be_grouped_into "itamae" }
end

describe file('/tmp/file_edit_with_content_change_updates_timestamp') do
  its(:mtime) { should be > DateTime.iso8601("2016-05-02T01:23:45Z") }
end

describe file('/tmp/file_edit_without_content_change_keeping_timestamp') do
  its(:mtime) { should eq(DateTime.iso8601("2016-05-02T12:34:56Z")) }
end

describe file('/home/itamae2') do
  it { should be_directory }
  it { should be_owned_by "itamae2" }
  it { should be_grouped_into "itamae2" }
end

describe file('/tmp/file_create_without_content') do
  its(:content) { should eq("Hello, World") }
  it { should be_mode 600 }
  it { should be_owned_by "itamae" }
  it { should be_grouped_into "itamae" }
end

describe file('/tmp/file_edit_notifies') do
  its(:content) { should eq("1") }
end

describe file('/tmp/file_without_content_change_updates_mode_and_owner') do
  its(:content) { should eq("Hello, world") }
  it { should be_mode 666 }
  it { should be_owned_by "itamae2" }
  it { should be_grouped_into "itamae2" }
end

describe file('/tmp/file_with_content_change_updates_timestamp') do
  its(:mtime) { should be > DateTime.iso8601("2016-05-01T01:23:45Z") }
end

describe file('/tmp/file_without_content_change_keeping_timestamp') do
  its(:mtime) { should eq(DateTime.iso8601("2016-05-01T12:34:56Z")) }
end

describe file('/tmp/subscribed_from_parent') do
  it { should be_file }
end

describe file('/tmp/empty_file1') do
  it { should exist }
  it { should be_file }
  its(:content) { should eq "" }
end

describe file('/tmp/empty_file2') do
  it { should exist }
  it { should be_file }
  its(:content) { should eq "" }
end

describe file('/tmp/empty_file3') do
  it { should exist }
  it { should be_file }
  its(:content) { should eq "" }
end
