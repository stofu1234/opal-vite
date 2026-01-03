package com.opalvite.intellij.lsp

import com.intellij.openapi.project.Project
import com.intellij.openapi.diagnostic.Logger
import com.opalvite.intellij.settings.OpalViteSettings
import com.redhat.devtools.lsp4ij.server.ProcessStreamConnectionProvider
import java.io.File

/**
 * Provides connection to opal-language-server via stdio.
 *
 * The server can be started in two ways:
 * 1. Globally installed: `npx opal-language-server --stdio`
 * 2. Local project: `node_modules/.bin/opal-language-server --stdio`
 */
class OpalLspConnectionProvider(private val project: Project) : ProcessStreamConnectionProvider() {

    private val logger = Logger.getInstance(OpalLspConnectionProvider::class.java)

    init {
        val settings = OpalViteSettings.getInstance()
        val commands = buildCommandList(settings)

        logger.info("Starting Opal Language Server with command: ${commands.joinToString(" ")}")

        super.setCommands(commands)
        super.setWorkingDirectory(project.basePath)
    }

    private fun buildCommandList(settings: OpalViteSettings): List<String> {
        val customPath = settings.serverPath

        // Use custom path if specified
        if (customPath.isNotBlank()) {
            return if (customPath.endsWith(".js")) {
                listOf("node", customPath, "--stdio")
            } else {
                listOf(customPath, "--stdio")
            }
        }

        // Try to find local installation in project
        val localCommands = findLocalServer()
        if (localCommands != null) {
            return localCommands
        }

        // Fall back to npx (global installation)
        return if (isWindows()) {
            listOf("cmd", "/c", "npx", "opal-language-server", "--stdio")
        } else {
            listOf("npx", "opal-language-server", "--stdio")
        }
    }

    private fun findLocalServer(): List<String>? {
        val basePath = project.basePath ?: return null

        // Check for built dist/server.js first
        val serverJsPath = "$basePath/packages/opal-language-server/dist/server.js"
        val serverJsFile = File(serverJsPath)
        if (serverJsFile.exists() && serverJsFile.isFile) {
            logger.info("Found local opal-language-server at: $serverJsPath")
            return listOf("node", serverJsPath, "--stdio")
        }

        // Check node_modules/.bin (npm link or installed)
        val binPath = "$basePath/node_modules/.bin/opal-language-server"
        val binFile = File(binPath)
        if (binFile.exists()) {
            logger.info("Found local opal-language-server at: $binPath")
            return if (isWindows()) {
                listOf("cmd", "/c", binPath, "--stdio")
            } else {
                listOf(binPath, "--stdio")
            }
        }

        return null
    }

    private fun isWindows(): Boolean {
        return System.getProperty("os.name").lowercase().contains("win")
    }
}
