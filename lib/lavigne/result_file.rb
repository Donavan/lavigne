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
      reader.first['data']
    end

    def next_feature_model
      return nil if reader.eof?
      Models::Cucumber::Feature.avro_raw_decode(value: next_feature)
    end

    def features
      @features ||= reader.to_a.map { |f| f['data'] }
    end

    def feature_models
      @feature_models ||= reader.to_a.map { |f| Models::Cucumber::Feature.avro_raw_decode(value: f['data']) }
    end

    def each_feature
      reader.each do |feature|
        yield(feature['data'])
      end
    end

    def each_feature_model
      reader.each do |feature|
        yield(Models::Cucumber::Feature.avro_raw_decode(value: feature['data']))
      end
    end

    private

    def _file_header(rec)
      @file_header = Models::FileHeader.new(rec)
    end

    def _run_info(rec)
      @run_info = Models::RunInfo.new(rec)
    end

    def _kvp(rec)
      kvp_data = {}
      rec['values'].each { |kvp| kvp_data[kvp['name']] = kvp_data[kvp['value']] }
      @other_headers[rec['name']] = kvp_data
    end

    def _read_headers
      rec = reader.first
      until _eoh?(rec)
        self.send("_#{rec['rec_type']}", rec['data'])
        rec = reader.first
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
      header['rec_type'] == :headers_end.to_s
    end
  end
end
