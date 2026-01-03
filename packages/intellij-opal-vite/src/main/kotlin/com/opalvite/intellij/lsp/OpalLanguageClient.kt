package com.opalvite.intellij.lsp

import com.intellij.openapi.project.Project
import com.redhat.devtools.lsp4ij.client.LanguageClientImpl

/**
 * Custom language client for Opal Language Server.
 * Extends the default LSP4IJ client with Opal-specific functionality.
 */
class OpalLanguageClient(project: Project) : LanguageClientImpl(project) {

    // Add custom client methods here if needed
    // For example, custom notification handlers

    override fun registerCapability(params: org.eclipse.lsp4j.RegistrationParams): java.util.concurrent.CompletableFuture<Void> {
        return super.registerCapability(params)
    }
}
