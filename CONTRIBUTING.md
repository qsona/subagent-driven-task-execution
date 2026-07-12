# Contributing

Issues and pull requests are welcome. Please keep the skill's primary audience
and instruction language Japanese, explain the behavior being changed, and
avoid adding host-specific assumptions without documenting them.

Before submitting a pull request, run:

```sh
ruby scripts/validate.rb
ruby test/validate_secret_scan_test.rb
bash scripts/package.sh
```

Do not commit generated archives, checksums, credentials, personal data, or
editor and operating-system metadata.
