ami_bucket := "altf4llc-nix-ami-uploads"

check:
  nix flake check

build profile:
  nix build --json --print-build-logs --no-link '.#{{profile}}'

publish-ami profile:
  #!/usr/bin/env bash
  set -euo pipefail
  BUILD_TIME=$(date +%s)
  IMAGE_NAME="altf4llc-{{profile}}-$BUILD_TIME"

  DERIVATION=$(just build {{profile}})
  OUTPUT=$(echo "$DERIVATION" | jq -r '.[].outputs.out')
  IMAGE_PATH=$(cd "$OUTPUT" && ls *.vhd)

  echo "Uploading VHD to S3."
  aws s3 cp "$OUTPUT/$IMAGE_PATH" "s3://{{ami_bucket}}/$IMAGE_NAME.vhd"

  echo "Starting snapshot import."
  TASK_ID=$(aws ec2 import-snapshot --disk-container "Format=VHD,UserBucket={S3Bucket={{ami_bucket}},S3Key=$IMAGE_NAME.vhd}" --output json | jq -r ".ImportTaskId")

  echo "Waiting for snapshot import to complete."
  until [[ $(aws ec2 describe-import-snapshot-tasks --import-task-ids "$TASK_ID" --output json | jq -r '.ImportSnapshotTasks[].SnapshotTaskDetail.Status') == "completed" ]]; do
    echo "Snapshot is not imported yet, waiting..."
    sleep 5
  done

  SNAPSHOT_ID=$(aws ec2 describe-import-snapshot-tasks --import-task-ids "$TASK_ID" --output json | jq -r '.ImportSnapshotTasks[].SnapshotTaskDetail.SnapshotId')

  echo "New snapshot is $SNAPSHOT_ID."

  AMI_ID=$(aws ec2 register-image --architecture x86_64 --ena-support --name "$IMAGE_NAME" --description "A NixOS AMI: {{profile}}" --block-device-mappings "DeviceName=/dev/sda1,Ebs={SnapshotId=$SNAPSHOT_ID}" --root-device-name /dev/sda1 | jq .ImageId)

  echo "AMI is registered: $AMI_ID"

  echo "Cleaning up image VHD from bucket"
  aws s3 rm "s3://{{ami_bucket}}/$IMAGE_NAME.vhd"
