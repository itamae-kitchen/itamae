file "/tmp/it_does_not_exist" do
  action :edit
  block do |content|
    content.gsub!("foo", "bar")
  end
end
