# define resource echo_hello
define :echo_hello, version: nil do
  file "put file in default_redefine.rb" do
    action :create
    path "/tmp/created_in_default_redefine"
    content 'Blah'
  end
end
