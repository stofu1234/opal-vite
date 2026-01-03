package com.opalvite.intellij.liveTemplates

import com.intellij.codeInsight.template.TemplateActionContext
import com.intellij.codeInsight.template.TemplateContextType

/**
 * Live template context for Opal/Ruby files.
 * Templates are available in Ruby files, especially those in app/opal/ directories.
 */
class OpalLiveTemplateContext : TemplateContextType("OPAL", "Opal") {

    override fun isInContext(templateActionContext: TemplateActionContext): Boolean {
        val file = templateActionContext.file
        val fileName = file.name

        // Check if it's a Ruby file
        if (!fileName.endsWith(".rb") && !fileName.endsWith(".opal")) {
            return false
        }

        // Check if it's in an Opal directory
        val path = file.virtualFile?.path ?: return true
        return path.contains("/app/opal/") ||
                path.contains("\\app\\opal\\") ||
                fileName.endsWith(".opal")
    }
}
