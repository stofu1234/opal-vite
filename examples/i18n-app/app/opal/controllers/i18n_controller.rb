# backtick_javascript: true

# I18nController - UI coordination for internationalization
#
# This controller is responsible for:
# - Managing language button states
# - Coordinating UI updates when locale changes
# - Handling form submissions
#
# Translation data is in Translations module
# Formatting logic is in I18nService
#
class I18nController < StimulusController
  include JsProxyEx
  include StimulusHelpers

  self.targets = %w[
    title subtitle languageLabel langBtn
    welcomeTitle welcomeMessage
    productsTitle
    product1Name product1Desc product1Price product1Stock
    product2Name product2Desc product2Price product2Stock
    product3Name product3Desc product3Price product3Stock
    notificationsTitle notification1 notification2 notification3
    dateTimeTitle currentDateLabel currentDate currentTimeLabel currentTime
    formTitle nameLabel nameInput emailLabel emailInput messageLabel messageInput submitBtn
    featuresTitle
    feature1Title feature1Desc feature2Title feature2Desc
    feature3Title feature3Desc feature4Title feature4Desc
    feature5Title feature5Desc feature6Title feature6Desc
    footerText
  ]

  self.values = { current_locale: :string }

  def connect
    @i18n_service = I18nService.new
    js_set_prop(:currentLocaleValue, @i18n_service.current_locale)
    update_active_button
    update_translations
  end

  # Action: Switch language
  def switch_language(event)
    current_target = event.current_target
    dataset = wrap_js(current_target.dataset)
    locale = dataset[:locale]

    return unless @i18n_service.valid_locale?(locale)

    @i18n_service.current_locale = locale
    js_set_prop(:currentLocaleValue, locale)
    update_active_button
    update_translations
  end

  # Action: Handle form submit
  def handle_submit(event)
    event.prevent_default
    message = @i18n_service.success_message
    `alert(#{message})`
  end

  private

  def update_active_button
    lang_btns = js_prop(:langBtnTargets)
    current_locale = @i18n_service.current_locale

    js_each(lang_btns) do |btn|
      btn_locale = js_get(js_get(btn, :dataset), :locale)
      class_list = js_get(btn, :classList)

      if `#{btn_locale} === #{current_locale}`
        js_call_on(class_list, :add, 'active')
      else
        js_call_on(class_list, :remove, 'active')
      end
    end
  end

  def update_translations
    t = @i18n_service.t
    return unless t

    update_text_targets(t)
    update_placeholders(t)
    update_pluralized_messages(t)
    update_prices
    update_date_time
    set_root_attr('lang', @i18n_service.current_locale)
  end

  def update_text_targets(t)
    # Main sections
    target_set_text(:title, js_get(t, :title)) if has_target?(:title)
    target_set_text(:subtitle, js_get(t, :subtitle)) if has_target?(:subtitle)
    target_set_text(:languageLabel, js_get(t, :languageLabel)) if has_target?(:languageLabel)
    target_set_text(:welcomeTitle, js_get(t, :welcomeTitle)) if has_target?(:welcomeTitle)
    target_set_text(:welcomeMessage, js_get(t, :welcomeMessage)) if has_target?(:welcomeMessage)

    # Products
    target_set_text(:productsTitle, js_get(t, :productsTitle)) if has_target?(:productsTitle)
    target_set_text(:product1Name, js_get(t, :product1Name)) if has_target?(:product1Name)
    target_set_text(:product1Desc, js_get(t, :product1Desc)) if has_target?(:product1Desc)
    target_set_text(:product2Name, js_get(t, :product2Name)) if has_target?(:product2Name)
    target_set_text(:product2Desc, js_get(t, :product2Desc)) if has_target?(:product2Desc)
    target_set_text(:product3Name, js_get(t, :product3Name)) if has_target?(:product3Name)
    target_set_text(:product3Desc, js_get(t, :product3Desc)) if has_target?(:product3Desc)

    # Notifications & DateTime
    target_set_text(:notificationsTitle, js_get(t, :notificationsTitle)) if has_target?(:notificationsTitle)
    target_set_text(:dateTimeTitle, js_get(t, :dateTimeTitle)) if has_target?(:dateTimeTitle)
    target_set_text(:currentDateLabel, js_get(t, :currentDateLabel)) if has_target?(:currentDateLabel)
    target_set_text(:currentTimeLabel, js_get(t, :currentTimeLabel)) if has_target?(:currentTimeLabel)

    # Form
    target_set_text(:formTitle, js_get(t, :formTitle)) if has_target?(:formTitle)
    target_set_text(:nameLabel, js_get(t, :nameLabel)) if has_target?(:nameLabel)
    target_set_text(:emailLabel, js_get(t, :emailLabel)) if has_target?(:emailLabel)
    target_set_text(:messageLabel, js_get(t, :messageLabel)) if has_target?(:messageLabel)
    target_set_text(:submitBtn, js_get(t, :submitBtn)) if has_target?(:submitBtn)

    # Features
    target_set_text(:featuresTitle, js_get(t, :featuresTitle)) if has_target?(:featuresTitle)
    target_set_text(:feature1Title, js_get(t, :feature1Title)) if has_target?(:feature1Title)
    target_set_text(:feature1Desc, js_get(t, :feature1Desc)) if has_target?(:feature1Desc)
    target_set_text(:feature2Title, js_get(t, :feature2Title)) if has_target?(:feature2Title)
    target_set_text(:feature2Desc, js_get(t, :feature2Desc)) if has_target?(:feature2Desc)
    target_set_text(:feature3Title, js_get(t, :feature3Title)) if has_target?(:feature3Title)
    target_set_text(:feature3Desc, js_get(t, :feature3Desc)) if has_target?(:feature3Desc)
    target_set_text(:feature4Title, js_get(t, :feature4Title)) if has_target?(:feature4Title)
    target_set_text(:feature4Desc, js_get(t, :feature4Desc)) if has_target?(:feature4Desc)
    target_set_text(:feature5Title, js_get(t, :feature5Title)) if has_target?(:feature5Title)
    target_set_text(:feature5Desc, js_get(t, :feature5Desc)) if has_target?(:feature5Desc)
    target_set_text(:feature6Title, js_get(t, :feature6Title)) if has_target?(:feature6Title)
    target_set_text(:feature6Desc, js_get(t, :feature6Desc)) if has_target?(:feature6Desc)

    # Footer (HTML)
    target_set_html(:footerText, js_get(t, :footerText)) if has_target?(:footerText)
  end

  def update_placeholders(t)
    placeholders = js_get(t, :placeholders)
    return unless placeholders

    if has_target?(:nameInput)
      name_input = get_target(:nameInput)
      js_set(name_input, :placeholder, js_get(placeholders, :name))
    end

    if has_target?(:emailInput)
      email_input = get_target(:emailInput)
      js_set(email_input, :placeholder, js_get(placeholders, :email))
    end

    if has_target?(:messageInput)
      message_input = get_target(:messageInput)
      js_set(message_input, :placeholder, js_get(placeholders, :message))
    end
  end

  def update_pluralized_messages(t)
    plurals = js_get(t, :plurals)
    return unless plurals

    message_forms = js_get(plurals, :message)
    item_forms = js_get(plurals, :item)

    # Notifications
    target_set_text(:notification1, @i18n_service.pluralize(message_forms, 1)) if has_target?(:notification1)
    target_set_text(:notification2, @i18n_service.pluralize(message_forms, 5)) if has_target?(:notification2)
    target_set_text(:notification3, @i18n_service.pluralize(message_forms, 0)) if has_target?(:notification3)

    # Stock messages
    target_set_text(:product1Stock, @i18n_service.pluralize(item_forms, 10)) if has_target?(:product1Stock)
    target_set_text(:product2Stock, @i18n_service.pluralize(item_forms, 1)) if has_target?(:product2Stock)
    target_set_text(:product3Stock, @i18n_service.pluralize(item_forms, 0)) if has_target?(:product3Stock)
  end

  def update_prices
    target_set_text(:product1Price, @i18n_service.format_currency(1299.99)) if has_target?(:product1Price)
    target_set_text(:product2Price, @i18n_service.format_currency(899.99)) if has_target?(:product2Price)
    target_set_text(:product3Price, @i18n_service.format_currency(349.99)) if has_target?(:product3Price)
  end

  def update_date_time
    now = js_date
    target_set_text(:currentDate, @i18n_service.format_date(now)) if has_target?(:currentDate)
    target_set_text(:currentTime, @i18n_service.format_time(now)) if has_target?(:currentTime)
  end
end
