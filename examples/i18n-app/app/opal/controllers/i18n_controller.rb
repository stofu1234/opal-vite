# backtick_javascript: true
require 'opal_stimulus/stimulus_controller'

class I18nController < StimulusController
  include StimulusHelpers

  self.targets = %w[
    title
    subtitle
    languageLabel
    langBtn
    welcomeTitle
    welcomeMessage
    productsTitle
    product1Name
    product1Desc
    product1Price
    product1Stock
    product2Name
    product2Desc
    product2Price
    product2Stock
    product3Name
    product3Desc
    product3Price
    product3Stock
    notificationsTitle
    notification1
    notification2
    notification3
    dateTimeTitle
    currentDateLabel
    currentDate
    currentTimeLabel
    currentTime
    formTitle
    nameLabel
    nameInput
    emailLabel
    emailInput
    messageLabel
    messageInput
    submitBtn
    featuresTitle
    feature1Title
    feature1Desc
    feature2Title
    feature2Desc
    feature3Title
    feature3Desc
    feature4Title
    feature4Desc
    feature5Title
    feature5Desc
    feature6Title
    feature6Desc
    footerText
  ]
  self.values = { current_locale: :string }

  def connect
    setup_translations
    setup_helper_functions
    setup_action_methods
    load_saved_locale
    update_translations
  end

  # Action: Switch language
  def switch_language
    js_call(:switchLanguage, `event`)
  end

  # Action: Handle form submit
  def handle_submit
    js_call(:handleSubmit, `event`)
  end

  private

  def setup_translations
    # Store translations as JavaScript object on controller
    `this.translations = {
      en: {
        title: '🌍 Internationalization Example',
        subtitle: 'Multi-language support with Stimulus + Opal',
        languageLabel: 'Select Language',
        welcomeTitle: 'Welcome!',
        welcomeMessage: 'This application demonstrates internationalization (i18n) features. Switch languages using the buttons above.',
        productsTitle: 'Featured Products',
        product1Name: 'Laptop',
        product1Desc: 'High-performance laptop for professionals',
        product2Name: 'Smartphone',
        product2Desc: 'Latest model with amazing camera',
        product3Name: 'Headphones',
        product3Desc: 'Wireless noise-cancelling headphones',
        notificationsTitle: 'Notifications',
        dateTimeTitle: 'Date & Time',
        currentDateLabel: 'Current Date:',
        currentTimeLabel: 'Current Time:',
        formTitle: 'Contact Form',
        nameLabel: 'Name',
        emailLabel: 'Email',
        messageLabel: 'Message',
        submitBtn: 'Send Message',
        featuresTitle: '✨ Features Demonstrated',
        feature1Title: '🌐 Multi-language',
        feature1Desc: 'Support for 5 languages: EN, JA, ES, FR, DE',
        feature2Title: '💾 localStorage',
        feature2Desc: 'Language preference persisted in browser',
        feature3Title: '🔢 Pluralization',
        feature3Desc: 'Smart handling of singular/plural forms',
        feature4Title: '💰 Number Formatting',
        feature4Desc: 'Currency and number formatting per locale',
        feature5Title: '📅 Date Formatting',
        feature5Desc: 'Locale-specific date and time formats',
        feature6Title: '⚡ Dynamic Switching',
        feature6Desc: 'Instant language switching without reload',
        footerText: 'Built with <a href="https://opalrb.com/" target="_blank">Opal</a>, <a href="https://stimulus.hotwired.dev/" target="_blank">Stimulus</a>, and <a href="https://vitejs.dev/" target="_blank">Vite</a>',
        placeholders: {
          name: 'Enter your name',
          email: 'Enter your email',
          message: 'Enter your message'
        },
        plurals: {
          message: {
            zero: 'You have no new messages',
            one: 'You have 1 new message',
            other: 'You have {count} new messages'
          },
          item: {
            zero: 'Out of stock',
            one: '1 item in stock',
            other: '{count} items in stock'
          }
        }
      },
      ja: {
        title: '🌍 国際化の例',
        subtitle: 'Stimulus + Opalによる多言語対応',
        languageLabel: '言語を選択',
        welcomeTitle: 'ようこそ！',
        welcomeMessage: 'このアプリケーションは国際化（i18n）機能を実演します。上のボタンで言語を切り替えてください。',
        productsTitle: '注目の商品',
        product1Name: 'ノートパソコン',
        product1Desc: 'プロフェッショナル向け高性能ノートパソコン',
        product2Name: 'スマートフォン',
        product2Desc: '素晴らしいカメラを搭載した最新モデル',
        product3Name: 'ヘッドフォン',
        product3Desc: 'ワイヤレスノイズキャンセリングヘッドフォン',
        notificationsTitle: '通知',
        dateTimeTitle: '日付と時刻',
        currentDateLabel: '現在の日付：',
        currentTimeLabel: '現在の時刻：',
        formTitle: 'お問い合わせフォーム',
        nameLabel: '名前',
        emailLabel: 'メールアドレス',
        messageLabel: 'メッセージ',
        submitBtn: '送信する',
        featuresTitle: '✨ デモンストレーション機能',
        feature1Title: '🌐 多言語対応',
        feature1Desc: '5つの言語をサポート：EN、JA、ES、FR、DE',
        feature2Title: '💾 localStorage',
        feature2Desc: 'ブラウザに言語設定を保存',
        feature3Title: '🔢 複数形処理',
        feature3Desc: '単数形・複数形の適切な処理',
        feature4Title: '💰 数値フォーマット',
        feature4Desc: 'ロケールごとの通貨と数値のフォーマット',
        feature5Title: '📅 日付フォーマット',
        feature5Desc: 'ロケール固有の日付と時刻の形式',
        feature6Title: '⚡ 動的切り替え',
        feature6Desc: 'リロードなしの即座の言語切り替え',
        footerText: '<a href="https://opalrb.com/" target="_blank">Opal</a>、<a href="https://stimulus.hotwired.dev/" target="_blank">Stimulus</a>、<a href="https://vitejs.dev/" target="_blank">Vite</a>で構築',
        placeholders: {
          name: 'お名前を入力',
          email: 'メールアドレスを入力',
          message: 'メッセージを入力'
        },
        plurals: {
          message: {
            zero: '新しいメッセージはありません',
            one: '新しいメッセージが1件あります',
            other: '新しいメッセージが{count}件あります'
          },
          item: {
            zero: '在庫なし',
            one: '在庫1点',
            other: '在庫{count}点'
          }
        }
      },
      es: {
        title: '🌍 Ejemplo de Internacionalización',
        subtitle: 'Soporte multiidioma con Stimulus + Opal',
        languageLabel: 'Seleccionar Idioma',
        welcomeTitle: '¡Bienvenido!',
        welcomeMessage: 'Esta aplicación demuestra características de internacionalización (i18n). Cambia de idioma usando los botones de arriba.',
        productsTitle: 'Productos Destacados',
        product1Name: 'Portátil',
        product1Desc: 'Portátil de alto rendimiento para profesionales',
        product2Name: 'Teléfono Inteligente',
        product2Desc: 'Último modelo con cámara increíble',
        product3Name: 'Auriculares',
        product3Desc: 'Auriculares inalámbricos con cancelación de ruido',
        notificationsTitle: 'Notificaciones',
        dateTimeTitle: 'Fecha y Hora',
        currentDateLabel: 'Fecha Actual:',
        currentTimeLabel: 'Hora Actual:',
        formTitle: 'Formulario de Contacto',
        nameLabel: 'Nombre',
        emailLabel: 'Correo Electrónico',
        messageLabel: 'Mensaje',
        submitBtn: 'Enviar Mensaje',
        featuresTitle: '✨ Características Demostradas',
        feature1Title: '🌐 Multiidioma',
        feature1Desc: 'Soporte para 5 idiomas: EN, JA, ES, FR, DE',
        feature2Title: '💾 localStorage',
        feature2Desc: 'Preferencia de idioma guardada en el navegador',
        feature3Title: '🔢 Pluralización',
        feature3Desc: 'Manejo inteligente de formas singulares/plurales',
        feature4Title: '💰 Formato de Números',
        feature4Desc: 'Formato de moneda y números por configuración regional',
        feature5Title: '📅 Formato de Fecha',
        feature5Desc: 'Formatos de fecha y hora específicos del idioma',
        feature6Title: '⚡ Cambio Dinámico',
        feature6Desc: 'Cambio instantáneo de idioma sin recargar',
        footerText: 'Construido con <a href="https://opalrb.com/" target="_blank">Opal</a>, <a href="https://stimulus.hotwired.dev/" target="_blank">Stimulus</a> y <a href="https://vitejs.dev/" target="_blank">Vite</a>',
        placeholders: {
          name: 'Ingrese su nombre',
          email: 'Ingrese su correo electrónico',
          message: 'Ingrese su mensaje'
        },
        plurals: {
          message: {
            zero: 'No tienes mensajes nuevos',
            one: 'Tienes 1 mensaje nuevo',
            other: 'Tienes {count} mensajes nuevos'
          },
          item: {
            zero: 'Agotado',
            one: '1 artículo en stock',
            other: '{count} artículos en stock'
          }
        }
      },
      fr: {
        title: "🌍 Exemple d'Internationalisation",
        subtitle: 'Support multilingue avec Stimulus + Opal',
        languageLabel: 'Sélectionner la Langue',
        welcomeTitle: 'Bienvenue !',
        welcomeMessage: "Cette application démontre les fonctionnalités d'internationalisation (i18n). Changez de langue en utilisant les boutons ci-dessus.",
        productsTitle: 'Produits en Vedette',
        product1Name: 'Ordinateur Portable',
        product1Desc: 'Ordinateur portable haute performance pour les professionnels',
        product2Name: 'Smartphone',
        product2Desc: 'Dernier modèle avec appareil photo incroyable',
        product3Name: 'Casque Audio',
        product3Desc: 'Casque sans fil à réduction de bruit',
        notificationsTitle: 'Notifications',
        dateTimeTitle: 'Date et Heure',
        currentDateLabel: 'Date Actuelle :',
        currentTimeLabel: 'Heure Actuelle :',
        formTitle: 'Formulaire de Contact',
        nameLabel: 'Nom',
        emailLabel: 'E-mail',
        messageLabel: 'Message',
        submitBtn: 'Envoyer le Message',
        featuresTitle: '✨ Fonctionnalités Démontrées',
        feature1Title: '🌐 Multilingue',
        feature1Desc: 'Support de 5 langues : EN, JA, ES, FR, DE',
        feature2Title: '💾 localStorage',
        feature2Desc: 'Préférence de langue conservée dans le navigateur',
        feature3Title: '🔢 Pluralisation',
        feature3Desc: 'Gestion intelligente des formes singulier/pluriel',
        feature4Title: '💰 Formatage des Nombres',
        feature4Desc: 'Formatage des devises et des nombres par locale',
        feature5Title: '📅 Formatage de Date',
        feature5Desc: 'Formats de date et heure spécifiques à la locale',
        feature6Title: '⚡ Changement Dynamique',
        feature6Desc: 'Changement de langue instantané sans rechargement',
        footerText: 'Construit avec <a href="https://opalrb.com/" target="_blank">Opal</a>, <a href="https://stimulus.hotwired.dev/" target="_blank">Stimulus</a> et <a href="https://vitejs.dev/" target="_blank">Vite</a>',
        placeholders: {
          name: 'Entrez votre nom',
          email: 'Entrez votre e-mail',
          message: 'Entrez votre message'
        },
        plurals: {
          message: {
            zero: "Vous n'avez aucun nouveau message",
            one: 'Vous avez 1 nouveau message',
            other: 'Vous avez {count} nouveaux messages'
          },
          item: {
            zero: 'Rupture de stock',
            one: '1 article en stock',
            other: '{count} articles en stock'
          }
        }
      },
      de: {
        title: '🌍 Internationalisierungsbeispiel',
        subtitle: 'Mehrsprachige Unterstützung mit Stimulus + Opal',
        languageLabel: 'Sprache Wählen',
        welcomeTitle: 'Willkommen!',
        welcomeMessage: 'Diese Anwendung demonstriert Internationalisierungs (i18n) Funktionen. Wechseln Sie die Sprache mit den Schaltflächen oben.',
        productsTitle: 'Ausgewählte Produkte',
        product1Name: 'Laptop',
        product1Desc: 'Hochleistungs-Laptop für Profis',
        product2Name: 'Smartphone',
        product2Desc: 'Neuestes Modell mit erstaunlicher Kamera',
        product3Name: 'Kopfhörer',
        product3Desc: 'Kabellose Kopfhörer mit Geräuschunterdrückung',
        notificationsTitle: 'Benachrichtigungen',
        dateTimeTitle: 'Datum und Uhrzeit',
        currentDateLabel: 'Aktuelles Datum:',
        currentTimeLabel: 'Aktuelle Uhrzeit:',
        formTitle: 'Kontaktformular',
        nameLabel: 'Name',
        emailLabel: 'E-Mail',
        messageLabel: 'Nachricht',
        submitBtn: 'Nachricht Senden',
        featuresTitle: '✨ Demonstrierte Funktionen',
        feature1Title: '🌐 Mehrsprachig',
        feature1Desc: 'Unterstützung für 5 Sprachen: EN, JA, ES, FR, DE',
        feature2Title: '💾 localStorage',
        feature2Desc: 'Sprachpräferenz im Browser gespeichert',
        feature3Title: '🔢 Pluralisierung',
        feature3Desc: 'Intelligente Handhabung von Singular-/Pluralformen',
        feature4Title: '💰 Zahlenformatierung',
        feature4Desc: 'Währungs- und Zahlenformatierung pro Gebietsschema',
        feature5Title: '📅 Datumsformatierung',
        feature5Desc: 'Gebietsschemaspezifische Datums- und Zeitformate',
        feature6Title: '⚡ Dynamischer Wechsel',
        feature6Desc: 'Sofortiger Sprachwechsel ohne Neuladen',
        footerText: 'Erstellt mit <a href="https://opalrb.com/" target="_blank">Opal</a>, <a href="https://stimulus.hotwired.dev/" target="_blank">Stimulus</a> und <a href="https://vitejs.dev/" target="_blank">Vite</a>',
        placeholders: {
          name: 'Geben Sie Ihren Namen ein',
          email: 'Geben Sie Ihre E-Mail ein',
          message: 'Geben Sie Ihre Nachricht ein'
        },
        plurals: {
          message: {
            zero: 'Sie haben keine neuen Nachrichten',
            one: 'Sie haben 1 neue Nachricht',
            other: 'Sie haben {count} neue Nachrichten'
          },
          item: {
            zero: 'Nicht vorrätig',
            one: '1 Artikel auf Lager',
            other: '{count} Artikel auf Lager'
          }
        }
      }
    }`
  end

  def setup_helper_functions
    # Define pluralize helper
    js_define_method(:pluralize) do |forms, count|
      key = if `#{count} === 0`
              'zero'
            elsif `#{count} === 1`
              'one'
            else
              'other'
            end
      template = js_get(forms, key.to_sym) || js_get(forms, :other)
      `#{template}.replace('{count}', #{count})`
    end

    # Define formatCurrency helper
    js_define_method(:formatCurrency) do |amount|
      locale = js_prop(:currentLocaleValue)
      currency = `#{locale} === 'ja' ? 'JPY' : 'USD'`
      begin
        intl = js_global('Intl')
        number_format = js_get(intl, :NumberFormat)
        formatter = js_new(number_format, locale, { style: 'currency', currency: currency }.to_n)
        js_call_on(formatter, :format, amount)
      rescue
        `'$' + #{amount}.toFixed(2)`
      end
    end

    # Define formatDate helper
    js_define_method(:formatDate) do |date|
      locale = js_prop(:currentLocaleValue)
      begin
        intl = js_global('Intl')
        date_format = js_get(intl, :DateTimeFormat)
        options = { year: 'numeric', month: 'long', day: 'numeric' }.to_n
        formatter = js_new(date_format, locale, options)
        js_call_on(formatter, :format, date)
      rescue
        `#{date}.toLocaleDateString()`
      end
    end

    # Define formatTime helper
    js_define_method(:formatTime) do |time|
      locale = js_prop(:currentLocaleValue)
      begin
        intl = js_global('Intl')
        date_format = js_get(intl, :DateTimeFormat)
        options = { hour: 'numeric', minute: 'numeric', hour12: `#{locale} === 'en'` }.to_n
        formatter = js_new(date_format, locale, options)
        js_call_on(formatter, :format, time)
      rescue
        `#{time}.toLocaleTimeString()`
      end
    end

    # Define updateTranslations helper
    js_define_method(:updateTranslations) do
      locale = js_prop(:currentLocaleValue)
      translations = js_prop(:translations)
      t = js_get(translations, locale.to_sym)
      next unless t

      # Update text content for all targets
      update_text_targets(t)
      update_placeholders(t)
      update_pluralized_messages(t)
      update_prices
      update_date_time
      set_root_attr('lang', locale)
    end
  end

  def setup_action_methods
    # Define switchLanguage action
    js_define_method(:switchLanguage) do |event|
      current_target = js_get(event, :currentTarget)
      dataset = js_get(current_target, :dataset)
      locale = js_get(dataset, :locale)
      translations = js_prop(:translations)

      unless js_get(translations, locale.to_sym)
        console_error('Unsupported locale:', locale)
        next
      end

      js_set_prop(:currentLocaleValue, locale)
      storage_set('preferredLocale', locale)

      # Update active button
      lang_btns = js_prop(:langBtnTargets)
      js_each(lang_btns) do |btn|
        class_list = js_get(btn, :classList)
        js_call_on(class_list, :remove, 'active')
      end

      current_class_list = js_get(current_target, :classList)
      js_call_on(current_class_list, :add, 'active')

      js_call(:updateTranslations)
    end

    # Define handleSubmit action
    js_define_method(:handleSubmit) do |event|
      `#{event}.preventDefault()`

      locale = js_prop(:currentLocaleValue)
      success_messages = {
        'en' => 'Message sent successfully!',
        'ja' => 'メッセージが送信されました！',
        'es' => '¡Mensaje enviado con éxito!',
        'fr' => 'Message envoyé avec succès !',
        'de' => 'Nachricht erfolgreich gesendet!'
      }

      message = success_messages[locale] || success_messages['en']
      `alert(#{message})`
    end
  end

  def load_saved_locale
    saved_locale = storage_get('preferredLocale')
    translations = js_prop(:translations)

    if saved_locale && js_get(translations, saved_locale.to_sym)
      js_set_prop(:currentLocaleValue, saved_locale)
    end
  end

  def update_translations
    js_call(:updateTranslations)
  end

  def update_text_targets(t)
    target_set_text(:title, js_get(t, :title)) if has_target?(:title)
    target_set_text(:subtitle, js_get(t, :subtitle)) if has_target?(:subtitle)
    target_set_text(:languageLabel, js_get(t, :languageLabel)) if has_target?(:languageLabel)
    target_set_text(:welcomeTitle, js_get(t, :welcomeTitle)) if has_target?(:welcomeTitle)
    target_set_text(:welcomeMessage, js_get(t, :welcomeMessage)) if has_target?(:welcomeMessage)
    target_set_text(:productsTitle, js_get(t, :productsTitle)) if has_target?(:productsTitle)
    target_set_text(:product1Name, js_get(t, :product1Name)) if has_target?(:product1Name)
    target_set_text(:product1Desc, js_get(t, :product1Desc)) if has_target?(:product1Desc)
    target_set_text(:product2Name, js_get(t, :product2Name)) if has_target?(:product2Name)
    target_set_text(:product2Desc, js_get(t, :product2Desc)) if has_target?(:product2Desc)
    target_set_text(:product3Name, js_get(t, :product3Name)) if has_target?(:product3Name)
    target_set_text(:product3Desc, js_get(t, :product3Desc)) if has_target?(:product3Desc)
    target_set_text(:notificationsTitle, js_get(t, :notificationsTitle)) if has_target?(:notificationsTitle)
    target_set_text(:dateTimeTitle, js_get(t, :dateTimeTitle)) if has_target?(:dateTimeTitle)
    target_set_text(:currentDateLabel, js_get(t, :currentDateLabel)) if has_target?(:currentDateLabel)
    target_set_text(:currentTimeLabel, js_get(t, :currentTimeLabel)) if has_target?(:currentTimeLabel)
    target_set_text(:formTitle, js_get(t, :formTitle)) if has_target?(:formTitle)
    target_set_text(:nameLabel, js_get(t, :nameLabel)) if has_target?(:nameLabel)
    target_set_text(:emailLabel, js_get(t, :emailLabel)) if has_target?(:emailLabel)
    target_set_text(:messageLabel, js_get(t, :messageLabel)) if has_target?(:messageLabel)
    target_set_text(:submitBtn, js_get(t, :submitBtn)) if has_target?(:submitBtn)
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
    target_set_text(:notification1, js_call(:pluralize, message_forms, 1)) if has_target?(:notification1)
    target_set_text(:notification2, js_call(:pluralize, message_forms, 5)) if has_target?(:notification2)
    target_set_text(:notification3, js_call(:pluralize, message_forms, 0)) if has_target?(:notification3)

    # Stock messages
    target_set_text(:product1Stock, js_call(:pluralize, item_forms, 10)) if has_target?(:product1Stock)
    target_set_text(:product2Stock, js_call(:pluralize, item_forms, 1)) if has_target?(:product2Stock)
    target_set_text(:product3Stock, js_call(:pluralize, item_forms, 0)) if has_target?(:product3Stock)
  end

  def update_prices
    target_set_text(:product1Price, js_call(:formatCurrency, 1299.99)) if has_target?(:product1Price)
    target_set_text(:product2Price, js_call(:formatCurrency, 899.99)) if has_target?(:product2Price)
    target_set_text(:product3Price, js_call(:formatCurrency, 349.99)) if has_target?(:product3Price)
  end

  def update_date_time
    now = js_date
    target_set_text(:currentDate, js_call(:formatDate, now)) if has_target?(:currentDate)
    target_set_text(:currentTime, js_call(:formatTime, now)) if has_target?(:currentTime)
  end
end
