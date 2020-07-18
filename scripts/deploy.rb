#!/bin/ruby

def set_stack_name(app_name: nil, branch_name: nil)
  app_name ||= ENV["AppName"]
  branch_name ||= ENV["CODEBUILD_GIT_BRANCH"]
  stack_name = if branch_name == "master"
    app_name
  else
    "#{make_name_cfn_friendly(app_name)}-#{make_name_cfn_friendly(branch_name)}"
  end
  stack_name
end

def make_name_cfn_friendly(name)
  invalid_characters_regex = /[[:punct:]]/
  valid_character = "-"
  invalid_characters = name.scan(invalid_characters_regex).flatten
  invalid_regex = Regexp.union(invalid_characters.reject { |chr| chr.match(valid_character) })
  name.gsub(invalid_regex, valid_character)
end

def delete_stack_on_merge(app_name:, branch_name:, commit_message:)
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
