# backtick_javascript: true
require 'opal_stimulus/stimulus_controller'

class I18nController < StimulusController
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
    `
      const ctrl = this;

      // Define translations
      ctrl.translations = {
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
          title: '🌍 Exemple d\'Internationalisation',
          subtitle: 'Support multilingue avec Stimulus + Opal',
          languageLabel: 'Sélectionner la Langue',
          welcomeTitle: 'Bienvenue !',
          welcomeMessage: 'Cette application démontre les fonctionnalités d\'internationalisation (i18n). Changez de langue en utilisant les boutons ci-dessus.',
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
              zero: 'Vous n\'avez aucun nouveau message',
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
      };

      // Helper functions defined as JavaScript
      ctrl.pluralize = function(forms, count) {
        let key = 'other';
        if (count === 0) {
          key = 'zero';
        } else if (count === 1) {
          key = 'one';
        }
        const template = forms[key] || forms.other;
        return template.replace('{count}', count);
      };

      ctrl.formatCurrency = function(amount) {
        try {
          return new Intl.NumberFormat(ctrl.currentLocaleValue, {
            style: 'currency',
            currency: ctrl.currentLocaleValue === 'ja' ? 'JPY' : 'USD'
          }).format(amount);
        } catch (e) {
          return '$' + amount.toFixed(2);
        }
      };

      ctrl.formatDate = function(date) {
        try {
          return new Intl.DateTimeFormat(ctrl.currentLocaleValue, {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
          }).format(date);
        } catch (e) {
          return date.toLocaleDateString();
        }
      };

      ctrl.formatTime = function(time) {
        try {
          return new Intl.DateTimeFormat(ctrl.currentLocaleValue, {
            hour: 'numeric',
            minute: 'numeric',
            hour12: ctrl.currentLocaleValue === 'en'
          }).format(time);
        } catch (e) {
          return time.toLocaleTimeString();
        }
      };

      ctrl.updateTranslations = function() {
        const t = ctrl.translations[ctrl.currentLocaleValue];
        if (!t) return;

        // Update text content
        if (ctrl.hasTitleTarget) ctrl.titleTarget.textContent = t.title;
        if (ctrl.hasSubtitleTarget) ctrl.subtitleTarget.textContent = t.subtitle;
        if (ctrl.hasLanguageLabelTarget) ctrl.languageLabelTarget.textContent = t.languageLabel;
        if (ctrl.hasWelcomeTitleTarget) ctrl.welcomeTitleTarget.textContent = t.welcomeTitle;
        if (ctrl.hasWelcomeMessageTarget) ctrl.welcomeMessageTarget.textContent = t.welcomeMessage;
        if (ctrl.hasProductsTitleTarget) ctrl.productsTitleTarget.textContent = t.productsTitle;
        if (ctrl.hasProduct1NameTarget) ctrl.product1NameTarget.textContent = t.product1Name;
        if (ctrl.hasProduct1DescTarget) ctrl.product1DescTarget.textContent = t.product1Desc;
        if (ctrl.hasProduct2NameTarget) ctrl.product2NameTarget.textContent = t.product2Name;
        if (ctrl.hasProduct2DescTarget) ctrl.product2DescTarget.textContent = t.product2Desc;
        if (ctrl.hasProduct3NameTarget) ctrl.product3NameTarget.textContent = t.product3Name;
        if (ctrl.hasProduct3DescTarget) ctrl.product3DescTarget.textContent = t.product3Desc;
        if (ctrl.hasNotificationsTitleTarget) ctrl.notificationsTitleTarget.textContent = t.notificationsTitle;
        if (ctrl.hasDateTimeTitleTarget) ctrl.dateTimeTitleTarget.textContent = t.dateTimeTitle;
        if (ctrl.hasCurrentDateLabelTarget) ctrl.currentDateLabelTarget.textContent = t.currentDateLabel;
        if (ctrl.hasCurrentTimeLabelTarget) ctrl.currentTimeLabelTarget.textContent = t.currentTimeLabel;
        if (ctrl.hasFormTitleTarget) ctrl.formTitleTarget.textContent = t.formTitle;
        if (ctrl.hasNameLabelTarget) ctrl.nameLabelTarget.textContent = t.nameLabel;
        if (ctrl.hasEmailLabelTarget) ctrl.emailLabelTarget.textContent = t.emailLabel;
        if (ctrl.hasMessageLabelTarget) ctrl.messageLabelTarget.textContent = t.messageLabel;
        if (ctrl.hasSubmitBtnTarget) ctrl.submitBtnTarget.textContent = t.submitBtn;
        if (ctrl.hasFeaturesTitleTarget) ctrl.featuresTitleTarget.textContent = t.featuresTitle;
        if (ctrl.hasFeature1TitleTarget) ctrl.feature1TitleTarget.textContent = t.feature1Title;
        if (ctrl.hasFeature1DescTarget) ctrl.feature1DescTarget.textContent = t.feature1Desc;
        if (ctrl.hasFeature2TitleTarget) ctrl.feature2TitleTarget.textContent = t.feature2Title;
        if (ctrl.hasFeature2DescTarget) ctrl.feature2DescTarget.textContent = t.feature2Desc;
        if (ctrl.hasFeature3TitleTarget) ctrl.feature3TitleTarget.textContent = t.feature3Title;
        if (ctrl.hasFeature3DescTarget) ctrl.feature3DescTarget.textContent = t.feature3Desc;
        if (ctrl.hasFeature4TitleTarget) ctrl.feature4TitleTarget.textContent = t.feature4Title;
        if (ctrl.hasFeature4DescTarget) ctrl.feature4DescTarget.textContent = t.feature4Desc;
        if (ctrl.hasFeature5TitleTarget) ctrl.feature5TitleTarget.textContent = t.feature5Title;
        if (ctrl.hasFeature5DescTarget) ctrl.feature5DescTarget.textContent = t.feature5Desc;
        if (ctrl.hasFeature6TitleTarget) ctrl.feature6TitleTarget.textContent = t.feature6Title;
        if (ctrl.hasFeature6DescTarget) ctrl.feature6DescTarget.textContent = t.feature6Desc;
        if (ctrl.hasFooterTextTarget) ctrl.footerTextTarget.innerHTML = t.footerText;

        // Update placeholders
        if (ctrl.hasNameInputTarget) ctrl.nameInputTarget.placeholder = t.placeholders.name;
        if (ctrl.hasEmailInputTarget) ctrl.emailInputTarget.placeholder = t.placeholders.email;
        if (ctrl.hasMessageInputTarget) ctrl.messageInputTarget.placeholder = t.placeholders.message;

        // Update pluralized messages
        if (ctrl.hasNotification1Target) {
          ctrl.notification1Target.textContent = ctrl.pluralize(t.plurals.message, 1);
        }
        if (ctrl.hasNotification2Target) {
          ctrl.notification2Target.textContent = ctrl.pluralize(t.plurals.message, 5);
        }
        if (ctrl.hasNotification3Target) {
          ctrl.notification3Target.textContent = ctrl.pluralize(t.plurals.message, 0);
        }

        // Update stock messages
        if (ctrl.hasProduct1StockTarget) {
          ctrl.product1StockTarget.textContent = ctrl.pluralize(t.plurals.item, 10);
        }
        if (ctrl.hasProduct2StockTarget) {
          ctrl.product2StockTarget.textContent = ctrl.pluralize(t.plurals.item, 1);
        }
        if (ctrl.hasProduct3StockTarget) {
          ctrl.product3StockTarget.textContent = ctrl.pluralize(t.plurals.item, 0);
        }

        // Update prices with locale-specific formatting
        if (ctrl.hasProduct1PriceTarget) {
          ctrl.product1PriceTarget.textContent = ctrl.formatCurrency(1299.99);
        }
        if (ctrl.hasProduct2PriceTarget) {
          ctrl.product2PriceTarget.textContent = ctrl.formatCurrency(899.99);
        }
        if (ctrl.hasProduct3PriceTarget) {
          ctrl.product3PriceTarget.textContent = ctrl.formatCurrency(349.99);
        }

        // Update date/time
        if (ctrl.hasCurrentDateTarget) {
          ctrl.currentDateTarget.textContent = ctrl.formatDate(new Date());
        }
        if (ctrl.hasCurrentTimeTarget) {
          ctrl.currentTimeTarget.textContent = ctrl.formatTime(new Date());
        }

        // Update document language
        document.documentElement.lang = ctrl.currentLocaleValue;
      };

      // Stimulus action methods
      this.switchLanguage = function(event) {
        const locale = event.currentTarget.dataset.locale;

        if (!ctrl.translations[locale]) {
          console.error('Unsupported locale:', locale);
          return;
        }

        ctrl.currentLocaleValue = locale;
        localStorage.setItem('preferredLocale', locale);

        // Update active button
        ctrl.langBtnTargets.forEach(function(btn) {
          btn.classList.remove('active');
        });
        event.currentTarget.classList.add('active');

        ctrl.updateTranslations();
      };

      this.handleSubmit = function(event) {
        event.preventDefault();

        const t = ctrl.translations[ctrl.currentLocaleValue];
        const successMessages = {
          en: 'Message sent successfully!',
          ja: 'メッセージが送信されました！',
          es: '¡Mensaje enviado con éxito!',
          fr: 'Message envoyé avec succès !',
          de: 'Nachricht erfolgreich gesendet!'
        };

        alert(successMessages[ctrl.currentLocaleValue] || successMessages.en);
      };

      // Load saved locale from localStorage
      const savedLocale = localStorage.getItem('preferredLocale');
      if (savedLocale && ctrl.translations[savedLocale]) {
        ctrl.currentLocaleValue = savedLocale;
      }

      // Apply initial translations
      ctrl.updateTranslations();
    `
  end
end
