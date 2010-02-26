require 'fastercsv'
require 'spreadsheet'

module Import
  
  # This class takes an uploaded file and parses out
  # appropriate upload information. 
  #
  # This is data-type agnostic. It simply parses files
  # according to rules for the given file type
  class Parser

    attr_accessor :errors, :data

    def initialize
      @errors = []
    end

    # Parse the uploaded file.
    # Resulting data will be in #data
    def parse(uploaded_file)
      parser_class = 
        case uploaded_file.content_type
        when "application/vnd.ms-excel"
          ExcelParser
        when "text/csv"
          CSVParser
        else
          self.errors << "Do not know how to parse #{uploaded_file.original_filename}. " +
                          "Expects .csv or .xls (Excel) files."
          nil
        end

      if parser_class
        @data = parser_class.new(self).parse(uploaded_file)
      end

      self.valid?
    end

    # Was the parse successful?
    def valid?
      @data && @errors.empty?
    end

    protected

    class FileParser
      attr_accessor :parent

      def initialize(parent)
        @parent = parent
      end

      def parse(file)
        raise "Must implement #parse"
      end
    end

    # Parse out data from an excel spreadsheet
    # This also works on OpenOffice.org Calc files
    class ExcelParser < FileParser
      def parse(file)
        begin
          book = Spreadsheet.open(file.path)
          data = []

          if book.worksheets.length == 1
            worksheet = book.worksheets[0]
            worksheet.each do |row|
              data << row.map {|e| e.to_s }
            end

            data
          else
            self.parent.errors << "The uploaded spreadsheet has to many worksheets (#{book.worksheets.length})."
            nil
          end
        end
      rescue Ole::Storage::FormatError => ex
        Rails.logger.error("Error parsing spreadsheet: #{ex}")
        self.parent.errors << "Unable to parse uploaded spreadsheet."
        nil
      end
    end

    # Parse out a .csv file
    class CSVParser < FileParser
      def parse(file)
        begin
          FasterCSV.parse(file.read)
        rescue FasterCSV::MalformedCSVError => ex
          Rails.logger.error("Error parsing CSV: #{ex}")
          self.parent.errors << "Unable to parse uploaded CSV file."
          nil
        end
      end
    end

  end

end
