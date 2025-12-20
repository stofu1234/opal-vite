# backtick_javascript: true

# I18nService - Internationalization formatting and locale management
#
# This service handles:
# - Locale storage and retrieval
# - Number/currency formatting
# - Date/time formatting
# - Pluralization
#
# Usage:
#   service = I18nService.new
#   service.current_locale = 'ja'
#   service.format_currency(1299.99)  # => "¥1,300"
#   service.format_date(js_date)      # => "2024年1月15日"
#
class I18nService
  include StimulusHelpers

  STORAGE_KEY = 'preferredLocale'.freeze

  attr_reader :translations

  def initialize
    @translations = Translations.data
    @current_locale = load_saved_locale || Translations::DEFAULT_LOCALE
  end

  # Get/set current locale
  def current_locale
    @current_locale
  end

  def current_locale=(locale)
    if Translations.supported?(locale)
      @current_locale = locale
      save_locale(locale)
    end
  end

  # Get translation for current locale
  def t
    return nil unless @translations
    result = `#{@translations}[#{@current_locale}]`
    return nil if `#{result} === undefined`
    result
  end

  # Check if locale is valid
  def valid_locale?(locale)
    # Use JS check to avoid Ruby method calls on potential JS undefined
    translations_valid = `typeof #{@translations} === 'object' && #{@translations} !== null`
    return false unless translations_valid
    `#{@translations}[#{locale}] !== undefined`
  end

  # Pluralize a message based on count
  #
  # @param forms [Native] JavaScript object with zero/one/other keys
  # @param count [Integer] The count to pluralize
  # @return [String] Pluralized message
  def pluralize(forms, count)
    key = case count
          when 0 then 'zero'
          when 1 then 'one'
          else 'other'
          end
    template = js_get(forms, key.to_sym) || js_get(forms, :other)
    `#{template}.replace('{count}', #{count})`
  end

  # Format currency based on current locale
  #
  # @param amount [Numeric] Amount to format
  # @return [String] Formatted currency string
  def format_currency(amount)
    currency = @current_locale == 'ja' ? 'JPY' : 'USD'
    begin
      intl = js_global('Intl')
      number_format = js_get(intl, :NumberFormat)
      formatter = js_new(number_format, @current_locale, { style: 'currency', currency: currency }.to_n)
      js_call_on(formatter, :format, amount)
    rescue
      "$#{`#{amount}.toFixed(2)`}"
    end
  end

  # Format date based on current locale
  #
  # @param date [Native] JavaScript Date object
  # @return [String] Formatted date string
  def format_date(date)
    begin
      intl = js_global('Intl')
      date_format = js_get(intl, :DateTimeFormat)
      options = { year: 'numeric', month: 'long', day: 'numeric' }.to_n
      formatter = js_new(date_format, @current_locale, options)
      js_call_on(formatter, :format, date)
    rescue
      `#{date}.toLocaleDateString()`
    end
  end

  # Format time based on current locale
  #
  # @param time [Native] JavaScript Date object
  # @return [String] Formatted time string
  def format_time(time)
    begin
      intl = js_global('Intl')
      date_format = js_get(intl, :DateTimeFormat)
      options = { hour: 'numeric', minute: 'numeric', hour12: @current_locale == 'en' }.to_n
      formatter = js_new(date_format, @current_locale, options)
      js_call_on(formatter, :format, time)
    rescue
      `#{time}.toLocaleTimeString()`
    end
  end

  # Get success message for current locale
  def success_message
    Translations.success_message(@current_locale)
  end

  private

  def load_saved_locale
    saved = storage_get(STORAGE_KEY)
    saved if saved && Translations.supported?(saved)
  end

  def save_locale(locale)
    storage_set(STORAGE_KEY, locale)
  end
end
