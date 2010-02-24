require 'test_helper'

module UploadHelper
  # We don't have access to this method here, it's available for
  # controller tests, so we'll just hack it ourselves.
  def fixture_file_upload(path, mime)
    ActionController::TestUploadedFile.new(
      ActionController::TestCase.fixture_path + path, mime)
  end
end

describe "Import::Parser", ActiveSupport::TestCase do

  context "Parsing Excel" do

    context "on a Good Excel file" do
      include UploadHelper

      setup do
        file = fixture_file_upload("import/proper_10.xls", "application/vnd.ms-excel")
        @parser = Import::Parser.new
        @parser.parse(file)
      end

      specify "is valid" do
        @parser.should.be.valid
      end

      specify "data contains proper data" do
        @parser.data.length.should.equal 10
      end

    end

    context "on a Bad Excel file" do
      include UploadHelper

      setup do
        file = fixture_file_upload("/tags.yml", "application/vnd.ms-excel")
        @parser = Import::Parser.new
        @parser.parse(file)
      end

      specify "is invalid" do
        @parser.should.not.be.valid
        @parser.errors[0].should.equal "Unable to parse uploaded spreadsheet."
      end
    end

    context "on an Excel file with > 1 worksheet" do
      include UploadHelper

      setup do
        file = fixture_file_upload("import/with_two_worksheets.xls", "application/vnd.ms-excel")
        @parser = Import::Parser.new
        @parser.parse(file)
      end

      specify "is invalid" do
        @parser.should.not.be.valid
        @parser.errors[0].should.equal "The uploaded spreadsheet has to many worksheets (2)."
      end
    end

  end

  context "Parsing CSV" do

    context "on Good CSV data" do
      include UploadHelper

      setup do
        file = fixture_file_upload("import/proper_10.csv", "text/csv")
        @parser = Import::Parser.new
        @parser.parse(file)
      end

      specify "parses valid csv file" do
        @parser.should.be.valid
      end

      specify "data contains the csv data" do
        @parser.data.length.should.equal 10
      end
    end

    context "on Bad CSV data" do
      include UploadHelper

      setup do
        file = fixture_file_upload("import/proper_10.xls", "text/csv")
        @parser = Import::Parser.new
        @parser.parse(file)
      end

      specify "should be invalid" do
        @parser.should.not.be.valid
        @parser.errors[0].should.equal "Unable to parse uploaded CSV file."
      end
    end
  end

  context "Bad file upload" do
    include UploadHelper

    setup do
      file = fixture_file_upload("/tags.yml", "text/yaml")
      @parser = Import::Parser.new
      @parser.parse(file)
    end

    specify "errors out" do
      @parser.should.not.be.valid
      @parser.errors[0].should.match /Do not know how to parse tags\.yml/
      @parser.data.should.be.nil
    end

  end

end
