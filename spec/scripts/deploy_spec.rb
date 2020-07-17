require "spec_helper.rb"

require_relative "../../scripts/deploy"

RSpec.describe "set_stack_name" do
  context "when the branch is not master" do
    let(:good_stack_name) { "app-name-some-weird-branch-name-2" }
    before do
      ENV["CODEBUILD_GIT_BRANCH"] = "some_weird_branch_name_2"
      ENV["AppName"] = "app-name"
    end
    it "sets the stack name to app name plus branch name" do
      expect(set_stack_name).to eq(good_stack_name)
    end
  end

  context "when the branch name is master" do
    before do
      ENV["CODEBUILD_GIT_BRANCH"] = "master"
      ENV["AppName"] = "app-name"
    end
    it "sets the stack name to app name without any suffix" do
      expect(set_stack_name).to eq("app-name")
    end
  end
  context "it fullfills the cloudformation stack name constraint" do
    let(:cloudformation_constraint) { /[a-zA-Z][-a-zA-Z0-9]*|arn:[-a-zA-Z0-9:\/._+]*/ }

    let(:good_stack_name) { "special-app-name-weird-branch-name" }

    before do
      ENV["CODEBUILD_GIT_BRANCH"] = "weird/branch/name"
      ENV["AppName"] = "special%app_name"
    end

    it "always makes sure that stack name fullfills" do
      expect(set_stack_name).to eq(good_stack_name)
    end
  end
end
