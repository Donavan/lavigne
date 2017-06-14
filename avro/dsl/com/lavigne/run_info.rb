namespace 'com.lavigne'
record :run_info do
  required :run_info_version, :long
  optional :suite_id, :string
  required :run_id, :string
  required :start_time, :long
  optional :hostname, :string
  optional :owner_id, :string
  optional :team_id, :string
  optional :project_id, :string
  optional :env, :array, items: :kv_pair
end
