require "spec_helper.rb"

require_relative "../../scripts/deploy"

RSpec.describe DeploymentScript do
  let(:app_name) { "app-name" }
  let(:branch_name) { "some_weird_branch_name_2" }
  subject(:script) { DeploymentScript }
  describe "#set_stack_name" do
    context "when the branch is not master" do
      let(:good_stack_name) { "app-name-some-weird-branch-name-2" }

      it "sets the stack name to app name plus branch name" do
        expect(script.set_stack_name(app_name: app_name, branch_name: branch_name, commit_message: "some-message")).to eq(good_stack_name)
      end
    end

    context "when the branch name is master" do
      let(:branch_name) { "master" }

      it "sets the stack name to app name without any suffix" do
        expect(script.set_stack_name(app_name: app_name, branch_name: branch_name, commit_message: "some-message")).to eq(app_name)
      end
    end

    context "when the branch name or app name has non-alpha numeric characters" do
      let(:good_stack_name) { "app-name-weird-branch-name-3" }
      let(:branch_name) { "weird/branch*name-3" }
      let(:app_name) { "app%name" }

      it "replaces any invalid character with a dash" do
        expect(script.set_stack_name(app_name: app_name, branch_name: branch_name, commit_message: "some-message")).to eq(good_stack_name)
      end
    end

    context "when the commit message indicates a merge commit" do
      let(:branch_name) { "some-branch-name" }
      let(:commit_message) { "Merge pull request #99 from repo/branch" }
      it "sets the stack name to app name without any suffix" do
        expect(script.set_stack_name(app_name: app_name, branch_name: branch_name, commit_message: commit_message)).to eq(app_name)
      end
    end
  end

  describe "#delete_stack_on_merge" do
    context "when commit message does not indicate a merge commit" do
      let(:commit_message) { "some-message" }
      it "does a no op" do
        expect(script.delete_stack_on_merge(app_name: app_name, branch_name: branch_name, commit_message: commit_message)).to be nil
      end
    end

    # context "when commit message indicates a merge commit" do
    #   let(:branch_name) { "branch_name" }
    #   let(:feature_branch_stack_name) { "app-name-branch-name" }
    #   let(:commit_message) { "Merge pull request #99 from repo/branch_name" }
    #   let(:cloudformation_get_buckets_command) {
    #     "aws cloudformation describe-stacks --stack-name " \
    #     "#{feature_branch_stack_name} --query "\
    #     "\"Stacks[].Outputs[contains(OutputKey, \'Bucket\')][OutputValue]\""
    #   }
    #   let(:s3_empty_bucket_command) { "aws s3 rm s3://#{bucket_1} --recursive" }

    #   let(:cloudformation_delete_stack_command) {
    #     "aws cloudformation delete-stack --stack-name #{feature_branch_stack_name}"
    #   }

    #   before do
    #     expect(DeploymentScript).to receive(:`).with(cloudformation_get_buckets_command).and_return([[["bucket-name-1", "bucket-name-2"]]].to_json)
    #   end

    #   it "empties any S3 Buckets and deletes the stack" do
    #     expect(DeploymentScript).to receive(:`).with("aws s3 rm s3://bucket-name-1 --recursive")
    #     expect(DeploymentScript).to receive(:`).with("aws s3 rm s3://bucket-name-2 --recursive")
    #     expect(DeploymentScript).to receive(:`).with(cloudformation_delete_stack_command)

    #     DeploymentScript.delete_stack_on_merge(app_name: app_name, branch_name: branch_name, commit_message: commit_message)
    #   end
    # end
  end
end
