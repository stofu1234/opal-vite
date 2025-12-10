# backtick_javascript: true
# Team class - Depends on Person class

require 'lib/person'

class Team
  attr_reader :name, :members

  def initialize(name)
    @name = name
    @members = []
  end

  def add_member(person)
    @members << person
    puts "Added #{person.name} to team #{@name}"
  end

  # Try changing this display format!
  def display
    result = "🎯 Team: #{@name}\n"
    result += "Members: #{@members.length}\n"
    @members.each do |member|
      result += "  - #{member.greet}\n"
    end
    result
  end

  def team_birthday
    puts "🎉 Team birthday celebration!"
    @members.each(&:birthday)
  end
end

puts "✅ Team class loaded (depends on Person)"
