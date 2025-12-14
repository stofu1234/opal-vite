class Router
  include Inesita::Router

  inject Store

  # Provide router method for child components
  def router
    @root_component
  end

  def routes
    route '/', to: Home
    route '/counter', to: Counter
    route '/todos', to: TodoList
    route '/about', to: About
  end
end
