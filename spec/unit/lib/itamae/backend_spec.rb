require 'spec_helper'
require 'fakefs/spec_helpers'

module Itamae
  module Backend
    describe Base do
      include FakeFS::SpecHelpers

      class Klass < Itamae::Backend::Base
        def initialize(_)
          @backend = Object.new
          @backend.stub(:send_file)
          @backend.stub(:send_directory)
        end
      end

      describe ".send_file" do
        context "the source file doesn't exist" do
          subject { -> { Klass.new("dummy").send_file("src", "dst") } }
          it { expect(subject).to raise_error(Itamae::Backend::SourceNotExistError, "The file 'src' doesn't exist.") }
        end

        context "the source file exist, but it is not a regular file" do
          before { Dir.mkdir("src")  }
          subject { -> { Klass.new("dummy").send_file("src", "dst") } }
          it { expect(subject).to raise_error(Itamae::Backend::SourceNotExistError, "'src' is not a file.") }
        end

        context "the source file is a regular file" do
          before { FileUtils.touch("src")  }
          subject { -> { Klass.new("dummy").send_file("src", "dst") } }
          it { expect { subject }.not_to raise_error }
        end
      end

      describe ".send_directory" do
        context "the source directory doesn't exist" do
          subject { -> { Klass.new("dummy").send_directory("src", "dst") } }
          it { expect(subject).to raise_error(Itamae::Backend::SourceNotExistError, "The directory 'src' doesn't exist.") }
        end

        context "the source directory exist, but it is not a directory" do
          before { FileUtils.touch("src")  }
          subject { -> { Klass.new("dummy").send_directory("src", "dst") } }
          it { expect(subject).to raise_error(Itamae::Backend::SourceNotExistError, "'src' is not a directory.") }
        end

        context "the source directory is a directory" do
          before { Dir.mkdir("src")  }
          subject { -> { Klass.new("dummy").send_directory("src", "dst") } }
          it { expect { subject }.not_to raise_error }
        end
      end
    end
  end
end
