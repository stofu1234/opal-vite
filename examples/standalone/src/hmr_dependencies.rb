# backtick_javascript: true
# HMR Dependency Test - Uses Team which uses Person

require 'lib/team'

puts "🔥 HMR Dependency Chain Test"
puts "Loading: hmr_dependencies -> team -> person"

# Create team
$team = Team.new("Opal Developers")

# Add members
$team.add_member(Person.new("Alice", 28))
$team.add_member(Person.new("Bob", 32))
$team.add_member(Person.new("Charlie", 25))

def update_display
  `
    const display = document.getElementById('team-display');
    if (display) {
      display.textContent = #{$team.display};
    }
  `
end

# Setup event handlers
`
  document.addEventListener('DOMContentLoaded', function() {
    console.log('🔥 HMR Dependency test initialized');

    #{update_display}

    const addBtn = document.getElementById('add-member');
    if (addBtn) {
      addBtn.addEventListener('click', function() {
        const names = ['David', 'Eve', 'Frank', 'Grace', 'Henry'];
        const name = names[Math.floor(Math.random() * names.length)];
        const age = Math.floor(Math.random() * 20) + 20;
        $team.add_member(#{Person}.new(name, age));
        #{update_display}
      });
    }

    const birthdayBtn = document.getElementById('team-birthday');
    if (birthdayBtn) {
      birthdayBtn.addEventListener('click', function() {
        $team.team_birthday();
        #{update_display}
      });
    }
  });

  // HMR Accept
  if (import.meta.hot) {
    import.meta.hot.accept((newModule) => {
      console.log('🔥 HMR: Dependency chain updated!');
      #{update_display}
    });
  }
`

puts "✅ HMR dependency test ready"
puts "Edit person.rb or team.rb to see cascading HMR updates!"
