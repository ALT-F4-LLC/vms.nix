# AWS

To use this repository with AWS, you need the following:

- An S3 bucket you have write access to
- A role called `vmimport` (exactly), using the included
  [trust policy](./vmimport_trust_policy.json) and
  [permissions](./vmimport_role_policy.json).

See the links above for what those policies should be.

Once done, you'll need to fork this repo and change the `ami_bucket` variable
in the [`justfile`](../justfile) to the name of your bucket.
