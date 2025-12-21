# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Internationalization', type: :feature do
  let(:i18n_controller_selector) { '[data-controller~="i18n"]' }
  let(:title_selector) { '[data-i18n-target="title"]' }
  let(:welcome_title_selector) { '[data-i18n-target="welcomeTitle"]' }

  describe 'language switching' do
    it 'switches to Japanese when clicking the Japanese button' do
      # Default should be English
      expect(page).to have_css(title_selector, text: 'Internationalization Example')

      # Switch to Japanese
      click_language('ja')

      # Verify Japanese text
      wait_for_text(title_selector, '国際化の例')
      expect(page).to have_css(welcome_title_selector, text: 'ようこそ！')
    end

    it 'switches to Spanish when clicking the Spanish button' do
      click_language('es')

      wait_for_text(title_selector, 'Internacionalización')
      expect(page).to have_css(welcome_title_selector, text: '¡Bienvenido!')
    end

    it 'switches to French when clicking the French button' do
      click_language('fr')

      wait_for_text(title_selector, 'Internationalisation')
      expect(page).to have_css(welcome_title_selector, text: 'Bienvenue')
    end

    it 'switches to German when clicking the German button' do
      click_language('de')

      wait_for_text(title_selector, 'Internationalisierungsbeispiel')
      expect(page).to have_css(welcome_title_selector, text: 'Willkommen!')
    end

    it 'switches back to English from another language' do
      # Switch to Japanese first
      click_language('ja')
      wait_for_text(welcome_title_selector, 'ようこそ！')

      # Switch back to English
      click_language('en')
      wait_for_text(welcome_title_selector, 'Welcome!')
    end
  end

  describe 'active button state' do
    it 'updates active class on language buttons' do
      # English button should be active by default
      en_btn = find('[data-locale="en"]')
      expect(en_btn[:class]).to include('active')

      # Switch to Japanese
      click_language('ja')

      # Japanese button should now be active
      ja_btn = find('[data-locale="ja"]')
      expect(ja_btn[:class]).to include('active')

      # English button should no longer be active
      en_btn = find('[data-locale="en"]')
      expect(en_btn[:class]).not_to include('active')
    end
  end

  describe 'localStorage persistence' do
    it 'persists language preference across page reloads' do
      # Switch to Japanese
      click_language('ja')
      wait_for_text(welcome_title_selector, 'ようこそ！')

      # Reload the page (without clearing localStorage)
      page.execute_script('location.reload()')
      wait_for_i18n_ready

      # Should still be Japanese
      wait_for_text(welcome_title_selector, 'ようこそ！')

      # Japanese button should be active
      ja_btn = find('[data-locale="ja"]')
      expect(ja_btn[:class]).to include('active')
    end
  end

  describe 'currency formatting' do
    let(:product1_price_selector) { '[data-i18n-target="product1Price"]' }

    it 'formats currency in USD for English locale' do
      wait_for_text(product1_price_selector, '$')
      price_text = find(product1_price_selector).text
      expect(price_text).to match(/\$[\d,]+\.?\d*/)
    end

    it 'formats currency in JPY for Japanese locale' do
      click_language('ja')

      # Japanese yen should be used (may be ¥ or full-width symbol)
      # Wait for price to change from USD format
      sleep 0.5
      price_text = find(product1_price_selector).text

      # Japanese yen can be displayed as ¥, JP¥, JPY, or full-width yen sign
      expect(price_text).to match(/(?:¥|￥|JP¥|JPY|円)[\d,]+|[\d,]+(?:円|¥|￥)/)
    end
  end

  describe 'pluralization' do
    let(:notification1_selector) { '[data-i18n-target="notification1"]' }
    let(:notification2_selector) { '[data-i18n-target="notification2"]' }
    let(:notification3_selector) { '[data-i18n-target="notification3"]' }
    let(:product1_stock_selector) { '[data-i18n-target="product1Stock"]' }
    let(:product2_stock_selector) { '[data-i18n-target="product2Stock"]' }
    let(:product3_stock_selector) { '[data-i18n-target="product3Stock"]' }

    it 'correctly pluralizes message counts in English' do
      # Wait for controller to initialize
      wait_for_i18n_ready

      # 1 message (singular)
      expect(page).to have_css(notification1_selector, text: '1 new message')
      # 5 messages (plural)
      expect(page).to have_css(notification2_selector, text: '5 new messages')
      # 0 messages (zero form)
      expect(page).to have_css(notification3_selector, text: 'no new messages')
    end

    it 'correctly pluralizes stock counts in English' do
      wait_for_i18n_ready

      # 10 items
      expect(page).to have_css(product1_stock_selector, text: '10 items in stock')
      # 1 item
      expect(page).to have_css(product2_stock_selector, text: '1 item in stock')
      # 0 items (out of stock)
      expect(page).to have_css(product3_stock_selector, text: 'Out of stock')
    end

    it 'correctly pluralizes in Japanese' do
      click_language('ja')

      # Japanese pluralization
      expect(page).to have_css(notification1_selector, text: '1件')
      expect(page).to have_css(notification2_selector, text: '5件')
    end
  end

  describe 'form placeholders' do
    let(:name_input_selector) { '[data-i18n-target="nameInput"]' }
    let(:email_input_selector) { '[data-i18n-target="emailInput"]' }

    it 'updates form placeholders in English' do
      wait_for_i18n_ready

      name_input = find(name_input_selector)
      expect(name_input[:placeholder]).to include('name')
    end

    it 'updates form placeholders when switching to Japanese' do
      click_language('ja')

      name_input = find(name_input_selector)
      expect(name_input[:placeholder]).to eq('お名前を入力')

      email_input = find(email_input_selector)
      expect(email_input[:placeholder]).to eq('メールアドレスを入力')
    end
  end

  describe 'date and time formatting' do
    let(:current_date_selector) { '[data-i18n-target="currentDate"]' }
    let(:current_time_selector) { '[data-i18n-target="currentTime"]' }

    it 'displays formatted date' do
      wait_for_i18n_ready

      date_text = find(current_date_selector).text
      # Date should be present and contain today's date info
      expect(date_text.length).to be > 0
      # Should contain year number (at least 4 digits together)
      expect(date_text).to match(/\d{4}|202\d/)
    end

    it 'displays formatted time' do
      wait_for_i18n_ready

      time_text = find(current_time_selector).text
      # Time should be present (contains numbers for hours/minutes)
      expect(time_text.length).to be > 0
      expect(time_text).to match(/\d+[:\uff1a]?\d+/)
    end
  end

  describe 'html lang attribute' do
    it 'updates the lang attribute on the html element' do
      wait_for_i18n_ready

      # Default should be English
      expect(find('html')['lang']).to eq('en')

      # Switch to Japanese
      click_language('ja')

      # Lang attribute should update
      expect(find('html')['lang']).to eq('ja')
    end
  end

  describe 'all supported locales work correctly' do
    %w[en ja es fr de].each do |locale|
      it "loads and displays content for #{locale} locale" do
        click_language(locale) unless locale == 'en'

        # All locales should have a title
        title = find(title_selector).text
        expect(title.length).to be > 0

        # All locales should have a welcome message
        welcome = find(welcome_title_selector).text
        expect(welcome.length).to be > 0
      end
    end
  end
end
