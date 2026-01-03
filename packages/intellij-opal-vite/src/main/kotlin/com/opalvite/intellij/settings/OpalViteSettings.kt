package com.opalvite.intellij.settings

import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.components.PersistentStateComponent
import com.intellij.openapi.components.Service
import com.intellij.openapi.components.State
import com.intellij.openapi.components.Storage
import com.intellij.util.xmlb.XmlSerializerUtil

/**
 * Persistent settings for Opal-Vite plugin.
 */
@Service
@State(
    name = "OpalViteSettings",
    storages = [Storage("OpalViteSettings.xml")]
)
class OpalViteSettings : PersistentStateComponent<OpalViteSettings> {

    var serverPath: String = ""
    var enableDiagnostics: Boolean = true
    var diagnosticSeverity: String = "warning"
    var autoDetectOpalFiles: Boolean = true

    override fun getState(): OpalViteSettings = this

    override fun loadState(state: OpalViteSettings) {
        XmlSerializerUtil.copyBean(state, this)
    }

    companion object {
        fun getInstance(): OpalViteSettings {
            return ApplicationManager.getApplication().getService(OpalViteSettings::class.java)
        }
    }
}
