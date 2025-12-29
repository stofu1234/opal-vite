#!/usr/bin/env node

import {
  createConnection,
  TextDocuments,
  Diagnostic,
  DiagnosticSeverity,
  ProposedFeatures,
  InitializeParams,
  TextDocumentSyncKind,
  InitializeResult,
  CompletionItem,
  TextDocumentPositionParams,
  DidChangeConfigurationNotification
} from 'vscode-languageserver/node';

import { TextDocument } from 'vscode-languageserver-textdocument';

import {
  getIncompatiblePatterns,
  getHintPatterns,
  compilePattern,
  IncompatiblePattern,
  HintPattern
} from './patterns.js';

import { getAllCompletionItems } from './snippets.js';

const connection = createConnection(ProposedFeatures.all);
const documents: TextDocuments<TextDocument> = new TextDocuments(TextDocument);

let hasConfigurationCapability = false;
let hasWorkspaceFolderCapability = false;

interface OpalServerSettings {
  enableDiagnostics: boolean;
  diagnosticSeverity: 'error' | 'warning' | 'information' | 'hint';
  autoDetectOpalFiles: boolean;
}

const defaultSettings: OpalServerSettings = {
  enableDiagnostics: true,
  diagnosticSeverity: 'warning',
  autoDetectOpalFiles: true
};

let globalSettings: OpalServerSettings = defaultSettings;
const documentSettings: Map<string, Thenable<OpalServerSettings>> = new Map();

connection.onInitialize((params: InitializeParams) => {
  const capabilities = params.capabilities;

  hasConfigurationCapability = !!(
    capabilities.workspace && !!capabilities.workspace.configuration
  );
  hasWorkspaceFolderCapability = !!(
    capabilities.workspace && !!capabilities.workspace.workspaceFolders
  );

  const result: InitializeResult = {
    capabilities: {
      textDocumentSync: TextDocumentSyncKind.Incremental,
      completionProvider: {
        resolveProvider: false,
        triggerCharacters: ['.', ':', "'", '"']
      },
      diagnosticProvider: {
        interFileDependencies: false,
        workspaceDiagnostics: false
      }
    }
  };

  if (hasWorkspaceFolderCapability) {
    result.capabilities.workspace = {
      workspaceFolders: {
        supported: true
      }
    };
  }

  return result;
});

connection.onInitialized(() => {
  if (hasConfigurationCapability) {
    connection.client.register(DidChangeConfigurationNotification.type, undefined);
  }
  connection.console.log('Opal Language Server initialized');
});

connection.onDidChangeConfiguration(change => {
  if (hasConfigurationCapability) {
    documentSettings.clear();
  } else {
    globalSettings = (change.settings.opalVite || defaultSettings) as OpalServerSettings;
  }

  documents.all().forEach(validateTextDocument);
});

function getDocumentSettings(resource: string): Thenable<OpalServerSettings> {
  if (!hasConfigurationCapability) {
    return Promise.resolve(globalSettings);
  }
  let result = documentSettings.get(resource);
  if (!result) {
    result = connection.workspace.getConfiguration({
      scopeUri: resource,
      section: 'opalVite'
    });
    documentSettings.set(resource, result);
  }
  return result;
}

documents.onDidClose(e => {
  documentSettings.delete(e.document.uri);
});

documents.onDidChangeContent(change => {
  validateTextDocument(change.document);
});

function isOpalFile(document: TextDocument, settings: OpalServerSettings): boolean {
  const uri = document.uri;

  if (uri.endsWith('.opal')) {
    return true;
  }

  if (!uri.endsWith('.rb')) {
    return false;
  }

  if (!settings.autoDetectOpalFiles) {
    return false;
  }

  if (uri.includes('/app/opal/') || uri.includes('\\app\\opal\\')) {
    return true;
  }

  const text = document.getText();
  const opalPatterns = [
    /`[^`]+`/,
    /\bNative\b/,
    /\bJS::/,
    /\bPromiseV2\b/,
    /\bOpalVite::/,
    /require\s+['"]opal/
  ];

  return opalPatterns.some(pattern => pattern.test(text));
}

function severityToLSP(severity: string, configuredSeverity: string): DiagnosticSeverity {
  if (severity === 'error') {
    return DiagnosticSeverity.Error;
  }

  switch (configuredSeverity) {
    case 'error':
      return DiagnosticSeverity.Error;
    case 'warning':
      return DiagnosticSeverity.Warning;
    case 'information':
      return DiagnosticSeverity.Information;
    case 'hint':
      return DiagnosticSeverity.Hint;
    default:
      return DiagnosticSeverity.Warning;
  }
}

async function validateTextDocument(textDocument: TextDocument): Promise<void> {
  const settings = await getDocumentSettings(textDocument.uri);

  if (!settings.enableDiagnostics) {
    connection.sendDiagnostics({ uri: textDocument.uri, diagnostics: [] });
    return;
  }

  if (!isOpalFile(textDocument, settings)) {
    return;
  }

  const text = textDocument.getText();
  const diagnostics: Diagnostic[] = [];

  const incompatiblePatterns = getIncompatiblePatterns();
  for (const patternDef of incompatiblePatterns) {
    const regex = compilePattern(patternDef.pattern);
    let match;

    while ((match = regex.exec(text)) !== null) {
      const startPos = textDocument.positionAt(match.index);
      const endPos = textDocument.positionAt(match.index + match[0].length);

      const diagnostic: Diagnostic = {
        severity: severityToLSP(patternDef.severity, settings.diagnosticSeverity),
        range: {
          start: startPos,
          end: endPos
        },
        message: `[Opal] ${patternDef.message}`,
        source: 'opal-language-server',
        code: patternDef.id
      };

      if (patternDef.documentation) {
        diagnostic.codeDescription = {
          href: patternDef.documentation
        };
      }

      diagnostics.push(diagnostic);
    }
  }

  const hintPatterns = getHintPatterns();
  for (const hintDef of hintPatterns) {
    const regex = compilePattern(hintDef.pattern);
    let match;

    while ((match = regex.exec(text)) !== null) {
      const startPos = textDocument.positionAt(match.index);
      const endPos = textDocument.positionAt(match.index + match[0].length);

      diagnostics.push({
        severity: DiagnosticSeverity.Hint,
        range: {
          start: startPos,
          end: endPos
        },
        message: hintDef.message,
        source: 'opal-language-server',
        code: hintDef.id
      });
    }
  }

  connection.sendDiagnostics({ uri: textDocument.uri, diagnostics });
}

connection.onCompletion(
  (_textDocumentPosition: TextDocumentPositionParams): CompletionItem[] => {
    return getAllCompletionItems();
  }
);

documents.listen(connection);
connection.listen();
