# spec/integration/recipes/redefine.rb
define :echo_hello, version: nil do
  file "put file in redefine.rb" do
    action :create
    path "/tmp/created_in_redefine"
    content 'first'
  end
end

# Duplicated definitions
define :echo_hello, version: nil do
  file "put file in redefine.rb" do
    action :create
    path "/tmp/created_in_redefine"
    content 'second'
  end
end

# Execute
echo_hello "execute echo_hello!"
