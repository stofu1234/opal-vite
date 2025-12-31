import * as path from 'path';
import * as vscode from 'vscode';

import {
  LanguageClient,
  LanguageClientOptions,
  ServerOptions,
  TransportKind
} from 'vscode-languageclient/node';

let client: LanguageClient | undefined;
let statusBarItem: vscode.StatusBarItem;
let diagnosticsEnabled = true;

export async function activate(context: vscode.ExtensionContext) {
  console.log('Opal Vite extension is now active');

  // Create status bar item
  statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
  statusBarItem.command = 'opalVite.toggleDiagnostics';
  updateStatusBar();
  statusBarItem.show();
  context.subscriptions.push(statusBarItem);

  // Get configuration
  const config = vscode.workspace.getConfiguration('opalVite');
  diagnosticsEnabled = config.get('enableDiagnostics', true);

  // Start the language server
  await startLanguageServer(context);

  // Register commands
  context.subscriptions.push(
    vscode.commands.registerCommand('opalVite.toggleDiagnostics', toggleDiagnostics),
    vscode.commands.registerCommand('opalVite.compileFile', compileCurrentFile),
    vscode.commands.registerCommand('opalVite.restartServer', async () => {
      await restartLanguageServer(context);
    })
  );

  // Watch for configuration changes
  context.subscriptions.push(
    vscode.workspace.onDidChangeConfiguration(async event => {
      if (event.affectsConfiguration('opalVite')) {
        const config = vscode.workspace.getConfiguration('opalVite');
        diagnosticsEnabled = config.get('enableDiagnostics', true);
        updateStatusBar();
      }
    })
  );
}

async function startLanguageServer(context: vscode.ExtensionContext): Promise<void> {
  // The server is provided by opal-language-server package
  // In development, we use the local build; in production, we bundle it

  // Try to find the server module
  const serverModule = findServerModule(context);

  if (!serverModule) {
    vscode.window.showWarningMessage(
      'Opal Language Server not found. Diagnostics will use fallback mode.'
    );
    // Use fallback mode (original implementation without LSP)
    activateFallbackMode(context);
    return;
  }

  const serverOptions: ServerOptions = {
    run: {
      module: serverModule,
      transport: TransportKind.ipc
    },
    debug: {
      module: serverModule,
      transport: TransportKind.ipc,
      options: {
        execArgv: ['--nolazy', '--inspect=6009']
      }
    }
  };

  const clientOptions: LanguageClientOptions = {
    documentSelector: [
      { scheme: 'file', language: 'ruby' },
      { scheme: 'file', language: 'opal' },
      { scheme: 'file', pattern: '**/app/opal/**/*.rb' }
    ],
    synchronize: {
      configurationSection: 'opalVite',
      fileEvents: vscode.workspace.createFileSystemWatcher('**/*.rb')
    },
    outputChannelName: 'Opal Language Server'
  };

  client = new LanguageClient(
    'opalLanguageServer',
    'Opal Language Server',
    serverOptions,
    clientOptions
  );

  await client.start();
  console.log('Opal Language Server started');
}

function findServerModule(context: vscode.ExtensionContext): string | null {
  // Try multiple locations for the server module

  // 1. Bundled with extension (production)
  const bundledPath = context.asAbsolutePath(
    path.join('server', 'dist', 'server.js')
  );

  // 2. Node modules (when installed as dependency)
  const nodeModulesPath = context.asAbsolutePath(
    path.join('node_modules', 'opal-language-server', 'dist', 'server.js')
  );

  // 3. Monorepo sibling package (development)
  const monoRepoPath = path.resolve(
    context.extensionPath,
    '..',
    'opal-language-server',
    'dist',
    'server.js'
  );

  const fs = require('fs');

  for (const serverPath of [bundledPath, nodeModulesPath, monoRepoPath]) {
    if (fs.existsSync(serverPath)) {
      console.log(`Found Opal Language Server at: ${serverPath}`);
      return serverPath;
    }
  }

  console.log('Opal Language Server not found, using fallback mode');
  return null;
}

async function restartLanguageServer(context: vscode.ExtensionContext): Promise<void> {
  if (client) {
    await client.stop();
  }
  await startLanguageServer(context);
  vscode.window.showInformationMessage('Opal Language Server restarted');
}

// Fallback mode: Use local diagnostics when LSP server is not available
function activateFallbackMode(context: vscode.ExtensionContext): void {
  const diagnosticCollection = vscode.languages.createDiagnosticCollection('opal');
  context.subscriptions.push(diagnosticCollection);

  // Import patterns inline for fallback
  const INCOMPATIBLE_PATTERNS: Array<{
    pattern: RegExp;
    message: string;
    severity: 'warning' | 'error';
  }> = [
    {
      pattern: /\bThread\.(new|start|fork|current|list|main|exclusive|kill)\b/g,
      message: 'Thread is not supported in Opal. JavaScript is single-threaded.',
      severity: 'error'
    },
    {
      pattern: /\bFile\.(read|write|open|delete|exist\?|exists\?|expand_path|dirname|basename|join|size|mtime|stat)\b/g,
      message: 'File operations are not available in browser Opal.',
      severity: 'error'
    },
    {
      pattern: /\bDir\.(pwd|chdir|glob|entries|mkdir|rmdir|exist\?|exists\?)\b/g,
      message: 'Dir operations are not available in browser Opal.',
      severity: 'error'
    },
    {
      pattern: /\b(TCPSocket|TCPServer|UDPSocket|UNIXSocket|Socket)\b/g,
      message: 'Socket operations are not available in browser Opal.',
      severity: 'error'
    },
    {
      pattern: /\brequire\s+['\"](nokogiri|mysql2|pg|sqlite3|redis|eventmachine)[\"\']/g,
      message: 'This gem uses native C extensions and is not available in Opal.',
      severity: 'error'
    }
  ];

  function analyzeDocument(document: vscode.TextDocument): void {
    if (!diagnosticsEnabled) {
      diagnosticCollection.delete(document.uri);
      return;
    }

    if (!isOpalFile(document)) {
      return;
    }

    const text = document.getText();
    const diagnostics: vscode.Diagnostic[] = [];

    for (const { pattern, message, severity } of INCOMPATIBLE_PATTERNS) {
      pattern.lastIndex = 0;
      let match;
      while ((match = pattern.exec(text)) !== null) {
        const startPos = document.positionAt(match.index);
        const endPos = document.positionAt(match.index + match[0].length);
        const range = new vscode.Range(startPos, endPos);

        diagnostics.push(new vscode.Diagnostic(
          range,
          `[Opal] ${message}`,
          severity === 'error'
            ? vscode.DiagnosticSeverity.Error
            : vscode.DiagnosticSeverity.Warning
        ));
      }
    }

    diagnosticCollection.set(document.uri, diagnostics);
  }

  function isOpalFile(document: vscode.TextDocument): boolean {
    if (document.languageId === 'opal') return true;
    if (document.languageId !== 'ruby') return false;

    const filePath = document.uri.fsPath;
    if (filePath.includes('/app/opal/') || filePath.includes('\\app\\opal\\')) {
      return true;
    }

    const text = document.getText();
    return /`[^`]+`|\bNative\b|\bJS::|\bPromiseV2\b|\bOpalVite::/.test(text);
  }

  context.subscriptions.push(
    vscode.workspace.onDidOpenTextDocument(analyzeDocument),
    vscode.workspace.onDidChangeTextDocument(e => analyzeDocument(e.document)),
    vscode.workspace.onDidCloseTextDocument(doc => diagnosticCollection.delete(doc.uri))
  );

  vscode.workspace.textDocuments.forEach(analyzeDocument);
}

function toggleDiagnostics(): void {
  diagnosticsEnabled = !diagnosticsEnabled;

  const config = vscode.workspace.getConfiguration('opalVite');
  config.update('enableDiagnostics', diagnosticsEnabled, vscode.ConfigurationTarget.Workspace);

  updateStatusBar();

  vscode.window.showInformationMessage(
    `Opal diagnostics ${diagnosticsEnabled ? 'enabled' : 'disabled'}`
  );
}

function updateStatusBar(): void {
  if (diagnosticsEnabled) {
    statusBarItem.text = '$(ruby) Opal';
    statusBarItem.tooltip = 'Opal Vite: Diagnostics enabled (click to toggle)';
    statusBarItem.backgroundColor = undefined;
  } else {
    statusBarItem.text = '$(ruby) Opal (off)';
    statusBarItem.tooltip = 'Opal Vite: Diagnostics disabled (click to toggle)';
    statusBarItem.backgroundColor = new vscode.ThemeColor('statusBarItem.warningBackground');
  }
}

async function compileCurrentFile(): Promise<void> {
  const editor = vscode.window.activeTextEditor;
  if (!editor) {
    vscode.window.showWarningMessage('No file is currently open');
    return;
  }

  const document = editor.document;
  const isRuby = document.languageId === 'ruby' || document.languageId === 'opal';

  if (!isRuby) {
    vscode.window.showWarningMessage('Current file is not a Ruby/Opal file');
    return;
  }

  await document.save();

  const terminal = vscode.window.createTerminal('Opal Vite');
  terminal.show();
  terminal.sendText(`bundle exec opal -c "${document.uri.fsPath}"`);
}

export async function deactivate(): Promise<void> {
  if (client) {
    await client.stop();
  }
  if (statusBarItem) {
    statusBarItem.dispose();
  }
}
