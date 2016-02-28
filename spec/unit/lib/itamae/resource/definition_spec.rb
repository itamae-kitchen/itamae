require 'spec_helper'
require 'tmpdir'
require 'itamae'

class DefineDefinitionTestResource < Itamae::Resource::Definition
  define_attribute :action, default: :create

  def self.dir
    @@dir
  end

  def self.dir=(dir)
    @@dir = dir
  end

  define_resource do
    file "#{DefineDefinitionTestResource.dir}/foo.txt" do
      content "bar"
    end
  end
end


describe DefineDefinitionTestResource do
  let(:backend) { Itamae::Backend.create(:local, {}) }
  let(:runner) { Itamae::Runner.new(backend, {}) }
  let(:recipe) do
    double(
      :recipe,
      runner: runner,
      path: File.expand_path("recipe1.rb"),
      children: runner.children)
  end

  around do |example|
    Dir.mktmpdir do |dir|
      DefineDefinitionTestResource.dir = dir
      Dir.chdir(dir) do
        example.run
      end
    end
  end

  before do
    described_class.new(recipe, 'definition resource')
  end

  it "" do
    runner.run
    expect(File.exist?(File.expand_path("foo.txt"))).to be_truthy
  end
end
