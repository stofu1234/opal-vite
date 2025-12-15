import React, { useState } from 'react'

export function TodoList() {
  const [todos, setTodos] = useState([])
  const [input, setInput] = useState('')

  const addTodo = () => {
    if (input.trim()) {
      setTodos([...todos, { text: input, completed: false }])
      setInput('')
    }
  }

  const toggleTodo = (index) => {
    const newTodos = todos.map((todo, i) =>
      i === index ? { ...todo, completed: !todo.completed } : todo
    )
    setTodos(newTodos)
  }

  const removeTodo = (index) => {
    setTodos(todos.filter((_, i) => i !== index))
  }

  const completedCount = todos.filter((t) => t.completed).length
  const activeCount = todos.length - completedCount

  return (
    <div className="todo-container">
      <div className="todo-card">
        <h2>Todo List Component</h2>

        <div className="todo-input-group">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && addTodo()}
            placeholder="Add a new todo..."
            className="todo-input"
          />
          <button onClick={addTodo} className="btn btn-add">
            + Add
          </button>
        </div>

        {todos.length === 0 ? (
          <div className="empty-state">
            <p>📝 No todos yet. Add one above!</p>
          </div>
        ) : (
          <>
            <ul className="todo-list">
              {todos.map((todo, index) => (
                <li
                  key={index}
                  className={`todo-item ${todo.completed ? 'completed' : ''}`}
                >
                  <input
                    type="checkbox"
                    checked={todo.completed}
                    onChange={() => toggleTodo(index)}
                    className="todo-checkbox"
                  />
                  <span
                    className="todo-text"
                    onClick={() => toggleTodo(index)}
                  >
                    {todo.text}
                  </span>
                  <button
                    onClick={() => removeTodo(index)}
                    className="btn-remove"
                  >
                    ×
                  </button>
                </li>
              ))}
            </ul>

            <div className="todo-stats">
              <p>
                Total: {todos.length} | Completed: {completedCount} | Active:{' '}
                {activeCount}
              </p>
            </div>
          </>
        )}
      </div>
    </div>
  )
}
