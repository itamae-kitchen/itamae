require 'spec_helper'
require 'tmpdir'

module Itamae
  describe Runner do
    subject { described_class.new(double(:node)) }

    around do |example|
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          example.run
        end
      end
    end

    describe ".run" do
      let(:recipes) { %w! ./recipe1.rb ./recipe2.rb ! }
      it "runs each recipe with the runner" do
        pending "Rewrite later"
        recipes.each do |r|
          recipe = double(:recipe)
          allow(Recipe).to receive(:new).with(
            an_instance_of(Itamae::Runner),
            File.expand_path(r)
          ).and_return(recipe)
          expect(recipe).to receive(:run)
        end
        described_class.run(recipes, :local, {})
      end

      it "raises error for invalid recipes argument type" do
        [nil, "recipe.rb"].each do |recipe|
          expect do
            described_class.run(recipe, :local, {})
          end.to raise_error(ArgumentError, 'recipe_files must be an Array')
        end
      end
    end

    describe "#initialize" do
      context "with multiple node_json and node_yaml files" do
        def build_temp_file(data)
          file = Tempfile.new
          file.write data
          file.close
          file
        end

        it "merges hashes and overwrites arrays" do
          json_one = build_temp_file %({ "vars_from_json": { "one": 1 }, "shared": { "foo": true } })
          json_two = build_temp_file %({ "vars_from_json": { "two": 2 } })
          yaml_one = build_temp_file %(
            vars_from_yaml:
              three: 3
            array:
              - 123
            shared:
              bar: false
          )
          yaml_two = build_temp_file %(
            vars_from_yaml:
              four: 4
            array:
              - 456
          )

          runner = described_class.new(
            spy,
            node_json: [json_one.path, json_two.path],
            node_yaml: [yaml_one.path, yaml_two.path]
          )

          expect(runner.node[:vars_from_json][:one]).to eq 1
          expect(runner.node[:vars_from_json][:two]).to eq 2
          expect(runner.node[:vars_from_yaml][:three]).to eq 3
          expect(runner.node[:vars_from_yaml][:four]).to eq 4
          expect(runner.node[:array]).to eq [456]
          expect(runner.node[:shared][:foo]).to eq true
          expect(runner.node[:shared][:bar]).to eq false
        end
      end
    end
  end
end
