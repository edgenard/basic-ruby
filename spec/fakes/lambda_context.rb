class FakeLambdaContext
  attr_accessor :function_name, :function_version, :invoked_function_arn,
    :memory_limit_in_mb, :aws_request_id, :log_group_name, :log_stream_name,
    :deadline_ms, :identity, :client_context

  def get_remaining_time_in_millis
    3000
  end
end
