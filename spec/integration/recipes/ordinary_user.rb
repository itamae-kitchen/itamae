user "create another ordinary user" do
  user 'root'
  uid 123
  username "itamae"
  password "$1$ltOY8bZv$iZ57f1KAp8jwKViNm3pze."
  home '/home/foo'
  shell '/bin/sh'
end

###

remote_file "/tmp/remote_file" do
  source "hello.txt"
end

remote_file "/tmp/remote_file_root" do
  user 'root'
  owner 'root'
  group 'root'
  source "hello.txt"
end

remote_file "/tmp/remote_file_another_ordinary" do
  user 'root'
  owner 'itamae'
  group 'itamae'
  source "hello.txt"
end

###

file "/tmp/file" do
  content "Hello World"
end

file "/tmp/file_root" do
  user 'root'
  owner 'root'
  group 'root'
  content 'Hello World'
end

file "/tmp/file_another_ordinary" do
  user 'root'
  owner 'itamae'
  group 'itamae'
  content 'Hello World'
end

###

template "/tmp/template" do
  source "hello.erb"
  variables goodbye: "Good bye"
end

template "/tmp/template_root" do
  user 'root'
  owner 'root'
  group 'root'
  source "hello.erb"
  variables goodbye: "Good bye"
end

template "/tmp/template_another_ordinary" do
  user 'root'
  owner 'itamae'
  group 'itamae'
  source "hello.erb"
  variables goodbye: "Good bye"
end

###

http_request "/tmp/http_request.html" do
  url "https://httpbin.org/get?from=itamae"
end

http_request "/tmp/http_request_root.html" do
  user 'root'
  owner 'root'
  group 'root'
  url "https://httpbin.org/get?from=itamae"
end

http_request "/tmp/http_request_another_ordinary.html" do
  user 'root'
  owner 'itamae'
  group 'itamae'
  url "https://httpbin.org/get?from=itamae"
end
