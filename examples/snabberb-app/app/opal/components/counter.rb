# Counter Component using Snabberb
#
# Demonstrates:
# - needs with default values and store
# - Event handling with lambda
# - State updates with store()
# - Conditional rendering
#
class Counter < Snabberb::Component
  needs :count, default: 0, store: true

  def render
    h(:div, [
      # Counter display
      h(:div, { class: { 'counter-display': true } }, [
        h(:div, { class: { 'count-value': true } }, @count.to_s)
      ]),

      # Controls
      h(:div, { class: { 'counter-controls': true } }, [
        h(:button, {
          class: { btn: true, 'btn-decrement': true },
          on: { click: -> { store(:count, @count - 1) } }
        }, '−'),
        h(:button, {
          class: { btn: true, 'btn-reset': true },
          on: { click: -> { store(:count, 0) } }
        }, 'Reset'),
        h(:button, {
          class: { btn: true, 'btn-increment': true },
          on: { click: -> { store(:count, @count + 1) } }
        }, '+')
      ]),

      # Info
      h(:div, { style: { textAlign: 'center', color: '#666' } }, [
        h(:p, "Current count: #{@count}"),
        h(:p, { class: { status: true } }, [status_display]),
        h(:p, { style: { marginTop: '0.5rem', fontSize: '0.85rem', color: '#999' } },
          "Double: #{@count * 2} | Absolute: #{@count.abs}")
      ])
    ])
  end

  private

  def status_display
    if @count > 0
      h(:span, { class: { positive: true } }, '↑ Positive')
    elsif @count < 0
      h(:span, { class: { negative: true } }, '↓ Negative')
    else
      h(:span, { class: { zero: true } }, '● Zero')
    end
  end
end
