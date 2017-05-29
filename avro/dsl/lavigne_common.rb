record :lavigne_file_header_v1 do
  required :lavigne_version, :string
  required :ruby_version, :string
  optional :cucumber_version, :string
end

# An environment variable and it's value
record :kv_pair do
  required :name, :string
  optional :value, :string
end

record :run_info_v1 do
  required :run_info_version, :long
  required :suite_id, :string
  required :run_id, :string
  required :start_time, :long
  optional :hostname, :string
  optional :owner_id, :string
  optional :team_id, :string
  optional :project_id, :string
  optional :env, :array,  items: :kv_pair
end

enum :header_type, symbols: [:file_header, :run_info, :kvp, :headers_end]

record :lavigne_kvp_header do
  required :name, :string
  required :values, :array, items: :kv_pair
end

record :lavigne_header do
  required :type, :header_type
  optional :header, union(:run_info_v1, :lavigne_file_header_v1, :lavigne_kvp_header)
end
