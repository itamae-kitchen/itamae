lvars = binding.local_variables
ivars = instance_variables

file "/tmp/local_variables" do
  content lvars.to_s
end

file "/tmp/instance_variables" do
  content ivars.to_s
end
