describe file('/tmp/file_as_ordinary_user') do
  it { should be_file }
  it { should be_owned_by "itamae" }
  it { should be_grouped_into "itamae" }
end

