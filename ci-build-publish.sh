#!/usr/bin/env bash
set -euo pipefail

bucket="$1"
profile="$2"

ci="${CI:-false}"

current_group=""
group() {
  # Starts a group (GitHub Actions)
  current_group="$1"
  if [[ "$ci" == "true" ]]; then
    echo "::group::$1";
  else
    echo "> $1"
  fi
}

endgroup() {
  # Ends the group (GitHub Actions)
  if [[ "$ci" == "true" ]]; then
    echo "::endgroup::"
  else
    echo "> Finished $current_group"
  fi
  current_group=""
}

ciout() {
  # Sets the value as a job output
  if [[ "$ci" == "true" ]]; then echo "$1=$2" >> "$GITHUB_OUTPUT"; fi
}

cisum() {
  if [[ "$ci" == "true" ]]; then
    echo "$@" >> "$GITHUB_STEP_SUMMARY"
  fi
}

build_time=$(date +%s)
image_name="altf4llc-$profile-$build_time"
ciout image_name "$image_name"

group "Building source VHD"
derivation=$(just build "$profile")
output=$(echo "$derivation" | jq -r '.[].outputs.out')
image_path=$(cd "$output" && ls -- *.vhd)
endgroup

group "Uploading VHD to S3"
aws s3 cp "$output/$image_path" "s3://$bucket/$image_name.vhd" --quiet
endgroup

group "Importing VHD as snapshot in EC2"
task_id=$(aws ec2 import-snapshot --disk-container "Format=VHD,UserBucket={S3Bucket=$bucket,S3Key=$image_name.vhd}" --output json | jq -r ".ImportTaskId")

echo "Waiting for snapshot import to complete."
until [[ $(aws ec2 describe-import-snapshot-tasks --import-task-ids "$task_id" --output json | jq -r '.ImportSnapshotTasks[].SnapshotTaskDetail.Status') == "completed" ]]; do
  echo "Snapshot is not imported yet, waiting..."
  sleep 5
done

snapshot_id=$(aws ec2 describe-import-snapshot-tasks --import-task-ids "$task_id" --output json | jq -r '.ImportSnapshotTasks[].SnapshotTaskDetail.SnapshotId')

echo "New snapshot is $snapshot_id."
ciout snapshot_id "$snapshot_id"
endgroup

group "Registering new AMI"
ami_id=$(aws ec2 register-image --architecture x86_64 --ena-support --name "$image_name" --description "A NixOS AMI: {{profile}}" --block-device-mappings "DeviceName=/dev/sda1,Ebs={SnapshotId=$snapshot_id}" --root-device-name /dev/sda1 | jq .ImageId)
echo "AMI is registered: $ami_id"
ciout ami_id "$ami_id"
endgroup

group "Cleaning up image VHD from bucket"
aws s3 rm "s3://$bucket/$image_name.vhd"
endgroup

cisum "# :rocket: AMI build successful"
cisum ""
cisum "An image was successfully built for Nix profile \`$profile\`."
cisum ""
cisum "- Build time: \`$build_time\`"
cisum "- VHD import job ID: \`$task_id\`"
cisum "- AMI ID: \`$ami_id\`"
cisum "- Snapshot ID: \`$snapshot_id\`"
