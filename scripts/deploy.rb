#!/bin/ruby

def set_stack_name
  app_name = ENV["AppName"]
  branch_name = ENV["CODEBUILD_GIT_BRANCH"]
  stack_name = if branch_name == "master"
    app_name
  else
    "#{app_name.gsub(/%|_|\//, "-")}-#{branch_name.gsub(/%|_|\//, "-")}"
  end
  stack_name
end

def run_from_command_line
  if $0 == __FILE__
    deploy
  end
end

def deploy
  system("sam deploy --parameter-overrides UrlExpiration=#{ENV["UrlExpiration"]} MaxFileSize=#{ENV["MaxFileSize"]} --stack-name=#{set_stack_name} --no-fail-on-empty-changeset")
end

run_from_command_line
