require 'spec_helper'
require 'fakefs/spec_helpers'

module Itamae
  module Backend
    describe Base do
      include FakeFS::SpecHelpers

      class Klass < Itamae::Backend::Base
        def initialize(_, backend)
          @backend = backend
        end
      end

      let(:backend) { double('backend', send_file: nil, send_directory: nil) }
      let(:itamae_backend) { Klass.new('dummy', backend) }

      describe ".send_file" do
        context "the source file doesn't exist" do
          subject { -> { itamae_backend.send_file("src", "dst") } }
          it { expect(subject).to raise_error(Itamae::Backend::SourceNotExistError, "The file 'src' doesn't exist.") }
        end

        context "the source file exist, but it is not a regular file" do
          before { Dir.mkdir("src")  }
          subject { -> { itamae_backend.send_file("src", "dst") } }
          it { expect(subject).to raise_error(Itamae::Backend::SourceNotExistError, "'src' is not a file.") }
        end

        context "the source file is a regular file" do
          before { FileUtils.touch("src")  }
          subject { -> { itamae_backend.send_file("src", "dst") } }
          it { expect { subject }.not_to raise_error }
        end
      end

      describe ".send_directory" do
        context "the source directory doesn't exist" do
          subject { -> { itamae_backend.send_directory("src", "dst") } }
          it { expect(subject).to raise_error(Itamae::Backend::SourceNotExistError, "The directory 'src' doesn't exist.") }
        end

        context "the source directory exist, but it is not a directory" do
          before { FileUtils.touch("src")  }
          subject { -> { itamae_backend.send_directory("src", "dst") } }
          it { expect(subject).to raise_error(Itamae::Backend::SourceNotExistError, "'src' is not a directory.") }
        end

        context "the source directory is a directory" do
          before { Dir.mkdir("src")  }
          subject { -> { itamae_backend.send_directory("src", "dst") } }
          it { expect { subject }.not_to raise_error }
        end
      end
    end

    describe Ssh do

      describe "#ssh_options" do
        subject { ssh.send(:ssh_options) }

        let!(:ssh) { described_class.new(options) }
        let!(:host_name) { "example.com" }
        let!(:default_option) do
          opts = {}
          opts[:host_name] = nil
          opts.merge!(Net::SSH::Config.for(host_name))
          opts[:user] = opts[:user] || Etc.getlogin
          opts
        end

        context "with host option" do
          let(:options) { {host: host_name} }
          it { is_expected.to eq( default_option.merge({host_name: host_name}) ) }
        end

        context "with ssh_config option" do
          around do |example|
            Tempfile.create("ssh_config") do |temp|
              temp.write(<<EOF)
Host ex1
  HostName example.com
  User myname
  Port 10022
EOF
              temp.flush
              @ssh_config = temp.path
              example.run
            end
          end

          let(:options) { {host: "ex1", ssh_config: @ssh_config} }

          it { is_expected.to a_hash_including({host_name: "example.com", user: "myname", port: 10022}) }
        end
      end

      describe "#disable_sudo?" do
        subject { ssh.send(:disable_sudo?) }

        let!(:ssh) { described_class.new(options)}

        context "when sudo option is true" do
          let(:options) { {sudo: true} }
          it { is_expected.to eq(false) }
        end

        context "when sudo option is false" do
          let(:options) { {sudo: false} }
          it { is_expected.to eq(true) }
        end
      end
    end
  end
end
