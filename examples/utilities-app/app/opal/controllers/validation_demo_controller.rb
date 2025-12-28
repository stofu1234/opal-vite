# backtick_javascript: true

# ValidationDemoController - Demonstrates validation utilities
#
# Features:
# - Email validation
# - URL validation
# - Phone validation
# - Blank/present checks
# - Length validation
# - Pattern matching
#
class ValidationDemoController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  self.targets = ["emailInput", "urlInput", "phoneInput", "textInput", "patternInput", "output"]

  def connect
    puts "ValidationDemoController connected"
  end

  # Action: Validate email
  def validate_email
    email = target_value(:emailInput)
    valid = valid_email?(email)

    show_result(:emailInput, valid, valid ? "Valid email address" : "Invalid email format")
  end

  # Action: Validate URL
  def validate_url
    url = target_value(:urlInput)
    valid = valid_url?(url)

    show_result(:urlInput, valid, valid ? "Valid URL" : "Invalid URL format")
  end

  # Action: Validate phone
  def validate_phone
    phone = target_value(:phoneInput)
    valid = valid_phone?(phone)

    show_result(:phoneInput, valid, valid ? "Valid phone number" : "Invalid phone format")
  end

  # Action: Check blank/present
  def check_blank
    text = target_value(:textInput)

    is_blank = blank?(text)
    is_present = present?(text)

    output = <<~HTML
      <div class="space-y-2">
        <div>
          <strong>blank?:</strong>
          <span class="#{is_blank ? 'text-orange-600' : 'text-green-600'}">#{is_blank}</span>
        </div>
        <div>
          <strong>present?:</strong>
          <span class="#{is_present ? 'text-green-600' : 'text-orange-600'}">#{is_present}</span>
        </div>
      </div>
    HTML

    show_output(output)
  end

  # Action: Check length
  def check_length
    text = target_value(:textInput)

    results = []
    results << { test: "min_length?(3)", result: min_length?(text, 3) }
    results << { test: "min_length?(10)", result: min_length?(text, 10) }
    results << { test: "max_length?(50)", result: max_length?(text, 50) }
    results << { test: "max_length?(5)", result: max_length?(text, 5) }

    items = results.map do |r|
      color = r[:result] ? 'text-green-600' : 'text-red-600'
      "<li><code>#{r[:test]}</code>: <span class='#{color}'>#{r[:result]}</span></li>"
    end.join

    length = text ? `#{text}.length` : 0

    output = <<~HTML
      <div class="space-y-2">
        <div><strong>Current length:</strong> #{length}</div>
        <ul class="list-disc list-inside">#{items}</ul>
      </div>
    HTML

    show_output(output)
  end

  # Action: Check pattern
  def check_pattern
    text = target_value(:textInput)
    pattern = target_value(:patternInput)

    if blank?(pattern)
      show_output("Please enter a pattern", "error")
      return
    end

    matches = matches_pattern?(text, pattern)

    output = <<~HTML
      <div class="space-y-2">
        <div><strong>Text:</strong> "#{text}"</div>
        <div><strong>Pattern:</strong> /#{pattern}/</div>
        <div>
          <strong>Matches:</strong>
          <span class="#{matches ? 'text-green-600' : 'text-red-600'}">#{matches}</span>
        </div>
      </div>
    HTML

    show_output(output)
  end

  # Action: Run all validations
  def validate_all
    results = []

    # Email
    email = target_value(:emailInput)
    results << { field: "Email", value: email, valid: present?(email) ? valid_email?(email) : nil }

    # URL
    url = target_value(:urlInput)
    results << { field: "URL", value: url, valid: present?(url) ? valid_url?(url) : nil }

    # Phone
    phone = target_value(:phoneInput)
    results << { field: "Phone", value: phone, valid: present?(phone) ? valid_phone?(phone) : nil }

    items = results.map do |r|
      if r[:valid].nil?
        status = "<span class='text-gray-400'>Empty</span>"
      elsif r[:valid]
        status = "<span class='text-green-600'>Valid</span>"
      else
        status = "<span class='text-red-600'>Invalid</span>"
      end

      "<tr><td class='border px-2 py-1'>#{r[:field]}</td><td class='border px-2 py-1'>#{r[:value] || '-'}</td><td class='border px-2 py-1'>#{status}</td></tr>"
    end.join

    output = <<~HTML
      <table class="w-full border-collapse">
        <thead>
          <tr class="bg-gray-100">
            <th class="border px-2 py-1 text-left">Field</th>
            <th class="border px-2 py-1 text-left">Value</th>
            <th class="border px-2 py-1 text-left">Status</th>
          </tr>
        </thead>
        <tbody>#{items}</tbody>
      </table>
    HTML

    show_output(output)
  end

  private

  def show_result(target_name, valid, message)
    output = <<~HTML
      <div class="flex items-center gap-2">
        <span class="#{valid ? 'text-green-600' : 'text-red-600'} text-xl">
          #{valid ? '✓' : '✗'}
        </span>
        <span>#{message}</span>
      </div>
    HTML

    show_output(output)
  end

  def show_output(html, type = "success")
    return unless has_target?(:output)

    color = type == "error" ? "text-red-600" : "text-gray-800"
    target_set_html(:output, "<div class='#{color}'>#{html}</div>")
  end
end
