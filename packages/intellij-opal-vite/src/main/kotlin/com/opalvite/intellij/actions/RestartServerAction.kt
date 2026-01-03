package com.opalvite.intellij.actions

import com.intellij.notification.NotificationGroupManager
import com.intellij.notification.NotificationType
import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.diagnostic.Logger
import com.redhat.devtools.lsp4ij.LanguageServerManager

/**
 * Action to restart the Opal Language Server.
 */
class RestartServerAction : AnAction() {

    private val logger = Logger.getInstance(RestartServerAction::class.java)

    override fun actionPerformed(e: AnActionEvent) {
        val project = e.project ?: return

        logger.info("Restarting Opal Language Server...")

        try {
            // Stop and restart all language servers for this project
            LanguageServerManager.getInstance(project).stop("opalLanguageServer")

            NotificationGroupManager.getInstance()
                .getNotificationGroup("Opal-Vite")
                .createNotification(
                    "Opal Language Server",
                    "Language server restarted successfully",
                    NotificationType.INFORMATION
                )
                .notify(project)

            logger.info("Opal Language Server restarted successfully")
        } catch (ex: Exception) {
            logger.error("Failed to restart Opal Language Server", ex)

            NotificationGroupManager.getInstance()
                .getNotificationGroup("Opal-Vite")
                .createNotification(
                    "Opal Language Server",
                    "Failed to restart language server: ${ex.message}",
                    NotificationType.ERROR
                )
                .notify(project)
        }
    }

    override fun update(e: AnActionEvent) {
        e.presentation.isEnabledAndVisible = e.project != null
    }
}
