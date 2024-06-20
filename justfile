ami_bucket := "altf4llc-nix-ami-uploads"

check:
  nix flake check

build profile:
  nix build --json --print-build-logs --no-link '.#{{profile}}'

publish-ami profile:
  bash ./ci-build-publish.sh "{{ami_bucket}}" "{{profile}}"

test profile arch='x86_64-linux':
  just build 'checks.{{arch}}.{{profile}}'
