#!/usr/bin/env bash
# Run an example's E2E suite. Headless Chrome sometimes fails to start in time
# on GitHub-hosted runners (Ferrum::ProcessTimeoutError). Retry once only in
# that case, so real failures (including flaky tests) still fail the job.
log=$(mktemp)
bundle exec rspec "$@" 2>&1 | tee "$log"
status=${PIPESTATUS[0]}
if [ "$status" -ne 0 ] && grep -q 'Ferrum::ProcessTimeoutError' "$log"; then
  echo "::warning::Chrome did not start in time; retrying the E2E suite once"
  bundle exec rspec "$@"
  status=$?
fi
exit "$status"
