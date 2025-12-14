class Counter
  include Inesita::Component

  def render
    div class: 'counter-container' do
      div class: 'nav-header' do
        a href: '/', onclick: router.method(:go_to) do
          text '← Back to Home'
        end
      end

      div class: 'counter-card' do
        h2 { text 'Counter Component' }

        div class: 'counter-display' do
          div class: 'count-value' do
            text store.counter
          end
        end

        div class: 'counter-controls' do
          button class: 'btn btn-decrement', onclick: method(:decrement) do
            text '− Decrement'
          end
          button class: 'btn btn-reset', onclick: method(:reset) do
            text '↺ Reset'
          end
          button class: 'btn btn-increment', onclick: method(:increment) do
            text '+ Increment'
          end
        end

        div class: 'counter-info' do
          p do
            text 'Current count: '
            span class: status_class do
              text store.counter
            end
          end
          p do
            text "Status: #{status_text}"
          end
        end
      end
    end
  end

  private

  def increment
    store.increase_counter
    render!
  end

  def decrement
    store.decrease_counter
    render!
  end

  def reset
    store.reset_counter
    render!
  end

  def status_class
    if store.counter > 0
      'positive'
    elsif store.counter < 0
      'negative'
    else
      'zero'
    end
  end

  def status_text
    if store.counter > 0
      'Positive'
    elsif store.counter < 0
      'Negative'
    else
      'Zero'
    end
  end
end
