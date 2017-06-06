module Lavigne
  class ResultFile
    attr_reader :reader, :file_header, :run_info, :other_headers

    def initialize(file)
      @other_headers = {}
      @reader = Lavigne.datafile_reader(file)
      _read_headers
    end

    def eof?
      reader.eof?
    end

    def next_feature
      return nil if reader.eof?
      reader.first['feature']
    end

    def features
      reader.to_a.map { |f| f['feature'] }
    end

    def each_feature
      reader.each do |feature|
        yield(feature['feature'])
      end
    end

    private

    def _read_headers
      header = reader.first['header']
      until _eoh?(header)
        _handle_header header
        header = reader.first['header']
      end
    end

    def _handle_header(header)
      case header['type']
      when 'run_info'
        @run_info = header['header']
      when 'file_header'
        @file_header = header['header']
      when 'kvp'
        @other_headers[header['header']['name']] = header['header']['values']
      end
    end

    def _eoh?(header)
      header['type'] == :headers_end.to_s
    end
  end
end
