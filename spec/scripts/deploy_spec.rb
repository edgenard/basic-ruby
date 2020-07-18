require "spec_helper.rb"

require_relative "../../scripts/deploy"

RSpec.describe "deploy script" do
  let(:app_name) { "app-name" }
  describe "#set_stack_name" do
    context "when the branch is not master" do
      let(:good_stack_name) { "app-name-some-weird-branch-name-2" }
      let(:branch_name) { "some_weird_branch_name_2" }

      it "sets the stack name to app name plus branch name" do
        expect(set_stack_name(app_name: app_name, branch_name: branch_name)).to eq(good_stack_name)
      end
    end

    context "when the branch name is master" do
      let(:branch_name) { "master" }

      it "sets the stack name to app name without any suffix" do
        expect(set_stack_name(app_name: app_name, branch_name: branch_name)).to eq(app_name)
      end
    end

    context "when the branch name has non-alpha numeric characters" do
      let(:good_stack_name) { "app-name-weird-branch-name-3" }
      let(:branch_name) { "weird/branch*name-3" }
      let(:app_name) { "app%name" }

      it "replaces any invalid character with a dash" do
        expect(set_stack_name(app_name: app_name, branch_name: branch_name)).to eq(good_stack_name)
      end
    end
  end

  describe "#delete_stack_on_merge" do
    context "when commit message does not indicate a merge commit" do
      it "does no op" do
        expect(delete_stack_on_merge(app_name: "some-app", branch_name: "some-branch", commit_message: "some-message")).to be nil
      end
    end

    context "when commit message indicates a merge commit" do
      it "empties any S3 Buckets"

      it "deletes the stack with the branch name"
    end
  end
end
