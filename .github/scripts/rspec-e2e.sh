#!/usr/bin/env bash
# Run an example's E2E suite. Headless Chrome sometimes fails to start in time
# on GitHub-hosted runners (Ferrum::ProcessTimeoutError). Retry once only when
# every failure is that timeout, so real failures (including flaky tests) still
# fail the job.
json=$(mktemp)
bundle exec rspec --format progress --format json --out "$json" "$@"
status=$?
[ "$status" -eq 0 ] && exit 0

if ruby -rjson -e '
  r = JSON.parse(File.read(ARGV[0]))
  failed = r["examples"].select { |e| e["status"] == "failed" }
  only_timeouts = r["summary"]["errors_outside_of_examples_count"].zero? &&
    failed.any? &&
    failed.all? { |e| e.dig("exception", "class") == "Ferrum::ProcessTimeoutError" }
  exit(only_timeouts ? 0 : 1)
' "$json" 2>/dev/null; then
  echo "::warning::Chrome did not start in time; retrying the E2E suite once"
  bundle exec rspec "$@"
  status=$?
fi
exit "$status"
