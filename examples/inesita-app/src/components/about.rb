class About
  include Inesita::Component

  def render
    div class: 'about-container' do
      div class: 'nav-header' do
        a href: '/', onclick: router.method(:go_to) do
          text '← Back to Home'
        end
      end

      div class: 'about-card' do
        h2 { text 'About This Example' }

        section class: 'about-section' do
          h3 { text 'What is Inesita?' }
          p do
            text 'Inesita is a simple, light Ruby frontend framework built on top of Opal. '
            text 'It uses Virtual DOM for efficient rendering and provides a component-based '
            text 'architecture for building modern web applications entirely in Ruby.'
          end
        end

        section class: 'about-section' do
          h3 { text 'Key Features' }
          ul do
            li { text '🧩 Component-based architecture' }
            li { text '⚡ Virtual DOM for fast rendering' }
            li { text '💎 Ruby DSL for HTML' }
            li { text '🔄 Client-side routing' }
            li { text '🗄️ Dependency injection for state management' }
          end
        end

        section class: 'about-section' do
          h3 { text 'Technology Stack' }
          div class: 'tech-list' do
            tech_item('Ruby', RUBY_VERSION)
            tech_item('Opal', Opal::VERSION)
            tech_item('Inesita', 'Frontend Framework')
            tech_item('Vite', 'Build Tool')
            tech_item('opal-vite', 'Integration Plugin')
          end
        end

        section class: 'about-section' do
          h3 { text 'Learn More' }
          div class: 'links' do
            external_link('Inesita Documentation', 'https://inesita.fazibear.me/')
            external_link('Opal Website', 'https://opalrb.com/')
            external_link('Vite Documentation', 'https://vitejs.dev/')
          end
        end
      end
    end
  end

  private

  def tech_item(name, version)
    div class: 'tech-item' do
      strong { text "#{name}: " }
      text version
    end
  end

  def external_link(name, url)
    a href: url, target: '_blank', rel: 'noopener noreferrer', class: 'external-link' do
      text "#{name} →"
    end
  end
end
