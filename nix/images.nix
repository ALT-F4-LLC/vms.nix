{ inputs, system }:
let
  inherit (import ./lib.nix { inherit inputs system; }) newAmazonImage;
in
{
  gc-fwd = newAmazonImage [
    ../modules/mixins/alloy-forwarder
  ];

  ecs-node = newAmazonImage [
    ../modules/mixins/ecs-agent
  ];

  actions-runner = newAmazonImage [
    ({ ... }: { amazonImage.sizeMB = 6 * 1024; })
    ../modules/mixins/github-actions
  ];
}
