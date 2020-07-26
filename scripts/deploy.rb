#!/bin/ruby
require "json"
module DeploymentScript
  def self.set_stack_name(app_name:, branch_name:, commit_message:)
    stack_name = if branch_name == "master" || merge_commit?(commit_message)
      make_cloudformation_friendly(app_name)
    else
      "#{make_cloudformation_friendly(app_name)}-#{make_cloudformation_friendly(branch_name)}"
    end
    stack_name
  end

  def self.merge_commit?(message)
    message.start_with?("Merge pull request")
  end

  def self.make_cloudformation_friendly(name)
    invalid_characters_regex = /[[:punct:]]/
    valid_character = "-"
    invalid_characters = name.scan(invalid_characters_regex).flatten
    invalid_regex = Regexp.union(invalid_characters.reject { |chr| chr.match(valid_character) })
    name.gsub(invalid_regex, valid_character)
  end

  def self.delete_stack_on_merge(app_name:, branch_name:, commit_message:)
    return nil unless merge_commit?(commit_message)
    stack_name = set_stack_name(app_name: app_name, branch_name: "feature-stacks", commit_message: "some-message") # Use fake commit message to make sure to get the stack name with branch suffix
    buckets = JSON.parse(`aws cloudformation describe-stacks --stack-name #{stack_name} --query "Stacks[].Outputs[?contains(OutputKey, 'Bucket')][OutputValue]"`).flatten
    buckets.each { |b| `aws s3 rm s3://#{b} --recursive` }
    `aws cloudformation delete-stack --stack-name #{stack_name}`
  end

  def self.deploy
    system("sam deploy --parameter-overrides UrlExpiration=#{ENV["UrlExpiration"]} MaxFileSize=#{ENV["MaxFileSize"]} --stack-name=#{set_stack_name(app_name: ENV["AppName"], branch_name: ENV["GIT_BRANCH"], commit_message: ENV["GIT_MESSAGE"])} --no-fail-on-empty-changeset")
  end
end

# When run from the command line
if $0 == __FILE__
  DeploymentScript.delete_stack_on_merge(app_name: ENV["AppName"], branch_name: ENV["GIT_BRANCH"], commit_message: ENV["GIT_MESSAGE"])
  DeploymentScript.deploy
end
