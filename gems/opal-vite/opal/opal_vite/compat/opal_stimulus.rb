# backtick_javascript: true
#
# Fixes for opal_stimulus (0.2.x) accessors that look up the wrong
# JavaScript property for multi-word names.
#
# opal_stimulus builds names such as "hasSoundButtonTarget" with
# String#capitalize, which lowercases the rest of the word ("hasSoundbuttonTarget"),
# and passes snake_case value names straight to Stimulus. As a result:
#
# - has_*_target / has_*_outlet / has_*_class always return undefined for
#   multi-word names
# - multi-word values read and write the wrong property, use the wrong
#   data attribute, and never fire *_value_changed
# - dashed outlet names (e.g. "user-status") read the wrong property and never
#   fire *_outlet_connected / *_outlet_disconnected
#
# Usage (after opal_stimulus, before defining controllers):
#
#   require 'opal_stimulus/stimulus_controller'
#   require 'opal_vite/compat/opal_stimulus'
#
# Values declared as `self.values = { latest_paid: :number }` then map to
# Stimulus' latestPaidValue / data-<controller>-latest-paid-value, as they
# would in a JavaScript controller.
require 'opal_stimulus/stimulus_controller'

module OpalVite
  module Compat
    module OpalStimulus
      # "soundButton" -> "SoundButton" (String#capitalize gives "Soundbutton")
      def self.upcase_first(name)
        str = name.to_s
        str.empty? ? str : str[0].upcase + str[1..-1]
      end

      # Stimulus' camelize: "latest_paid" / "user-status" -> "latestPaid" / "userStatus"
      def self.camelize(name)
        name.to_s.gsub(/[_-]([a-z0-9])/) { $1.upcase }
      end

      # Stimulus' namespaceCamelize for outlet names ("admin--user-status" -> "adminUserStatus")
      def self.namespace_camelize(name)
        camelize(name.to_s.gsub('--', '-').gsub('__', '_'))
      end

      module ClassMethods
        def targets=(targets = [])
          super

          targets.each do |target|
            has_prop = "has#{OpalStimulus.upcase_first(target)}Target"
            define_method("has_#{to_ruby_name(target)}_target") do
              `this[#{has_prop}]`
            end
          end
        end

        def outlets=(outlets = [])
          super

          outlets.each do |outlet|
            ruby_name = to_ruby_name(outlet).tr('-', '_')
            js_name = OpalStimulus.namespace_camelize(outlet)
            outlet_prop = "#{js_name}Outlet"
            outlets_prop = "#{js_name}Outlets"
            has_prop = "has#{OpalStimulus.upcase_first(js_name)}Outlet"

            define_method("#{ruby_name}_outlet") do
              `this[#{outlet_prop}]`
            end

            define_method("#{ruby_name}_outlets") do
              `this[#{outlets_prop}]`
            end

            define_method("has_#{ruby_name}_outlet") do
              `this[#{has_prop}]`
            end

            # Stimulus calls the camelized callbacks; forward them to Ruby.
            ["connected", "disconnected"].each do |event|
              snake_case_callback = "#{ruby_name}_outlet_#{event}"
              camel_case_callback = "#{js_name}Outlet#{OpalStimulus.upcase_first(event)}"
              %x{
                #{stimulus_controller}.prototype[#{camel_case_callback}] = function(outlet, element) {
                  if (this['$respond_to?'] && this['$respond_to?'](#{snake_case_callback})) {
                    return this['$' + #{snake_case_callback}](outlet, element);
                  }
                }
              }
            end
          end
        end

        # Stimulus uses the class key as-is for xxxClass / xxxClasses, so only
        # the has_ accessor needs fixing.
        def classes=(class_names = [])
          super

          class_names.each do |class_name|
            has_prop = "has#{OpalStimulus.upcase_first(class_name)}Class"
            define_method("has_#{to_ruby_name(class_name)}_class") do
              `this[#{has_prop}]`
            end
          end
        end

        # Replaces (does not wrap) the original: the original registers
        # snake_case keys with Stimulus, which changes the data attribute
        # name, so it cannot be fixed after the fact.
        def values=(values_hash = {})
          js_values = {}

          values_hash.each do |name, type|
            ruby_name = to_ruby_name(name)
            js_name = OpalStimulus.camelize(ruby_name)

            js_type = case type
            when :string then `String`
            when :number then `Number`
            when :boolean then `Boolean`
            when :array then `Array`
            when :object then `Object`
            else
              raise ArgumentError,
                "Unsupported value type: #{type}, please use :string, :number, :boolean, :array, or :object"
            end

            js_values[js_name] = js_type

            value_prop = "#{js_name}Value"
            has_prop = "has#{OpalStimulus.upcase_first(js_name)}Value"

            define_method("#{ruby_name}_value") do
              Native(`this[#{value_prop}]`)
            end

            define_method("#{ruby_name}_value=") do |value|
              Native(`this[#{value_prop}] = #{value}`)
            end

            define_method("has_#{ruby_name}") do
              `this[#{has_prop}]`
            end

            snake_case_changed = "#{ruby_name}_value_changed"
            camel_case_changed = "#{js_name}ValueChanged"
            %x{
              #{stimulus_controller}.prototype[#{camel_case_changed}] = function(value, previousValue) {
                if (#{type == :object}) {
                  value = JSON.stringify(value)
                  previousValue = JSON.stringify(previousValue)
                }
                if (this['$respond_to?'] && this['$respond_to?'](#{snake_case_changed})) {
                  return this['$' + #{snake_case_changed}](value, previousValue);
                }
              }
            }
          end

          `#{stimulus_controller}.values = #{js_values.to_n}`
        end
      end
    end
  end
end

StimulusController.singleton_class.prepend(OpalVite::Compat::OpalStimulus::ClassMethods)
