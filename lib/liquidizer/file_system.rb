module Liquidizer
  # File system for liquid that loads the templates from the database
  class FileSystem
    def initialize(&block)
      @source = block
    end

    def read_template_file(template_path)
      record = @source.call.find_by_name(template_path)
      record && record.content
    end
  end
end
