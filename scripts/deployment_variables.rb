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
