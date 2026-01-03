package com.opalvite.intellij.settings

import com.intellij.openapi.fileChooser.FileChooserDescriptorFactory
import com.intellij.openapi.options.Configurable
import com.intellij.openapi.ui.TextFieldWithBrowseButton
import com.intellij.ui.components.JBCheckBox
import com.intellij.ui.components.JBLabel
import com.intellij.ui.dsl.builder.*
import javax.swing.JComponent
import javax.swing.JPanel
import javax.swing.JComboBox
import javax.swing.DefaultComboBoxModel

/**
 * Settings UI for Opal-Vite plugin.
 */
class OpalViteSettingsConfigurable : Configurable {

    private var settingsPanel: JPanel? = null
    private var serverPathField: TextFieldWithBrowseButton? = null
    private var enableDiagnosticsCheckbox: JBCheckBox? = null
    private var diagnosticSeverityCombo: JComboBox<String>? = null
    private var autoDetectCheckbox: JBCheckBox? = null

    override fun getDisplayName(): String = "Opal-Vite"

    override fun createComponent(): JComponent {
        val settings = OpalViteSettings.getInstance()

        serverPathField = TextFieldWithBrowseButton().apply {
            addBrowseFolderListener(
                "Select Opal Language Server",
                "Select the path to opal-language-server executable",
                null,
                FileChooserDescriptorFactory.createSingleFileDescriptor()
            )
            text = settings.serverPath
        }

        enableDiagnosticsCheckbox = JBCheckBox("Enable diagnostics", settings.enableDiagnostics)

        diagnosticSeverityCombo = JComboBox(DefaultComboBoxModel(arrayOf("error", "warning", "information", "hint"))).apply {
            selectedItem = settings.diagnosticSeverity
        }

        autoDetectCheckbox = JBCheckBox("Auto-detect Opal files in app/opal/ directories", settings.autoDetectOpalFiles)

        settingsPanel = panel {
            group("Language Server") {
                row("Server path:") {
                    cell(serverPathField!!)
                        .align(AlignX.FILL)
                        .comment("Leave empty to use globally installed opal-language-server via npx")
                }
            }

            group("Diagnostics") {
                row {
                    cell(enableDiagnosticsCheckbox!!)
                }
                row("Severity level:") {
                    cell(diagnosticSeverityCombo!!)
                        .comment("Severity level for Opal-incompatible pattern warnings")
                }
                row {
                    cell(autoDetectCheckbox!!)
                }
            }

            group("Information") {
                row {
                    browserLink("Documentation", "https://stofu1234.github.io/opal-vite/")
                }
                row {
                    browserLink("Report Issues", "https://github.com/stofu1234/opal-vite/issues")
                }
            }
        }

        return settingsPanel!!
    }

    override fun isModified(): Boolean {
        val settings = OpalViteSettings.getInstance()
        return serverPathField?.text != settings.serverPath ||
                enableDiagnosticsCheckbox?.isSelected != settings.enableDiagnostics ||
                diagnosticSeverityCombo?.selectedItem != settings.diagnosticSeverity ||
                autoDetectCheckbox?.isSelected != settings.autoDetectOpalFiles
    }

    override fun apply() {
        val settings = OpalViteSettings.getInstance()
        settings.serverPath = serverPathField?.text ?: ""
        settings.enableDiagnostics = enableDiagnosticsCheckbox?.isSelected ?: true
        settings.diagnosticSeverity = diagnosticSeverityCombo?.selectedItem as? String ?: "warning"
        settings.autoDetectOpalFiles = autoDetectCheckbox?.isSelected ?: true
    }

    override fun reset() {
        val settings = OpalViteSettings.getInstance()
        serverPathField?.text = settings.serverPath
        enableDiagnosticsCheckbox?.isSelected = settings.enableDiagnostics
        diagnosticSeverityCombo?.selectedItem = settings.diagnosticSeverity
        autoDetectCheckbox?.isSelected = settings.autoDetectOpalFiles
    }

    override fun disposeUIResources() {
        settingsPanel = null
        serverPathField = null
        enableDiagnosticsCheckbox = null
        diagnosticSeverityCombo = null
        autoDetectCheckbox = null
    }
}
