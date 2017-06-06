namespace 'com.lavigne'


enum :record_type, symbols: [:header, :feature,:file_header, :run_info, :kvp, :headers_end]

record :lavigne_record do
  required :rec_type, :record_type
  optional :data, union(:run_info, :lavigne_file_header, :kvp_header, :bytes)
end