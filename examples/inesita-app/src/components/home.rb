class Home
  include Inesita::Component

  def render
    div class: 'home-container' do
      div class: 'hero' do
        h1 do
          text '🚀 Inesita + Opal + Vite'
        end
        p class: 'subtitle' do
          text 'A Ruby frontend framework powered by Virtual DOM'
        end
      end

      div class: 'features' do
        feature_card(
          title: 'Component-Based',
          icon: '🧩',
          description: 'Build reusable components with Ruby'
        )
        feature_card(
          title: 'Virtual DOM',
          icon: '⚡',
          description: 'Fast and efficient rendering'
        )
        feature_card(
          title: 'Ruby DSL',
          icon: '💎',
          description: 'Write HTML using Ruby syntax'
        )
        feature_card(
          title: 'State Management',
          icon: '🗄️',
          description: 'Dependency injection for shared state'
        )
      end

      div class: 'navigation-links' do
        h2 { text 'Try the Examples' }
        div class: 'nav-grid' do
          nav_link('/counter', '🔢 Counter', 'Interactive counter component')
          nav_link('/todos', '✅ Todo List', 'Manage your tasks')
          nav_link('/about', 'ℹ️ About', 'Learn more about this example')
        end
      end
    end
  end

  private

  def feature_card(title:, icon:, description:)
    div class: 'feature-card' do
      div class: 'feature-icon' do
        text icon
      end
      h3 { text title }
      p { text description }
    end
  end

  def nav_link(path, title, description)
    a href: path, onclick: ->(e) {
      `#{e}.preventDefault()`
      router.go_to(path)
      false
    } do
      div class: 'nav-card' do
        h3 { text title }
        p { text description }
      end
    end
  end
end
