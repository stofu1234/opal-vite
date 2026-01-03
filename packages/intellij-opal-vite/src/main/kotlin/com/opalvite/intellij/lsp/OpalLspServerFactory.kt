package com.opalvite.intellij.lsp

import com.intellij.openapi.project.Project
import com.redhat.devtools.lsp4ij.LanguageServerFactory
import com.redhat.devtools.lsp4ij.client.LanguageClientImpl
import com.redhat.devtools.lsp4ij.server.StreamConnectionProvider

/**
 * Factory for creating Opal Language Server connections.
 * Uses opal-language-server npm package.
 */
class OpalLspServerFactory : LanguageServerFactory {

    override fun createConnectionProvider(project: Project): StreamConnectionProvider {
        return OpalLspConnectionProvider(project)
    }

    override fun createLanguageClient(project: Project): LanguageClientImpl {
        return OpalLanguageClient(project)
    }
}
