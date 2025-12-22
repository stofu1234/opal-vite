# CounterService - Pure Ruby business logic (解決策①)
#
# This class contains all business logic without any JavaScript dependency.
# It can be tested with pure Ruby specs and reused across different frameworks.
#
# Usage:
#   service = CounterService.new
#   service.increment
#   service.count  # => 1
#
class CounterService
  attr_reader :count

  def initialize(initial_count = 0)
    @count = initial_count
  end

  def increment
    @count += 1
  end

  def decrement
    @count -= 1
  end

  def reset
    @count = 0
  end

  # Computed values
  def doubled
    @count * 2
  end

  def absolute
    @count.abs
  end

  def status
    if @count > 0
      :positive
    elsif @count < 0
      :negative
    else
      :zero
    end
  end
end
