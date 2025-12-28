import * as vscode from 'vscode';

// Opal incompatible patterns with explanations
const INCOMPATIBLE_PATTERNS: Array<{
  pattern: RegExp;
  message: string;
  severity: 'warning' | 'error' | 'information';
}> = [
  // Threading and concurrency
  {
    pattern: /\bThread\.(new|start|fork|current|list|main|exclusive|kill)\b/g,
    message: 'Thread is not supported in Opal. JavaScript is single-threaded. Consider using PromiseV2 for async operations.',
    severity: 'error'
  },
  {
    pattern: /\bMutex\.(new|lock|unlock|synchronize)\b/g,
    message: 'Mutex is not available in Opal. JavaScript is single-threaded.',
    severity: 'error'
  },
  {
    pattern: /\bQueue\.(new|push|pop|shift)\b/g,
    message: 'Queue (thread-safe) is not available in Opal.',
    severity: 'error'
  },
  // File system operations
  {
    pattern: /\bFile\.(read|write|open|delete|exist\?|exists\?|expand_path|dirname|basename|join|size|mtime|stat)\b/g,
    message: 'File operations are not available in browser Opal. Use fetch API for remote files.',
    severity: 'error'
  },
  {
    pattern: /\bDir\.(pwd|chdir|glob|entries|mkdir|rmdir|exist\?|exists\?)\b/g,
    message: 'Dir operations are not available in browser Opal.',
    severity: 'error'
  },
  {
    pattern: /\bIO\.(read|write|popen|pipe|select)\b/g,
    message: 'IO operations are not available in browser Opal.',
    severity: 'error'
  },
  // Process and system
  {
    pattern: /\bProcess\.(pid|ppid|kill|fork|wait|spawn|exec)\b/g,
    message: 'Process operations are not available in Opal.',
    severity: 'error'
  },
  {
    pattern: /\b(system|exec|fork|spawn)\s*[\(\s]/g,
    message: 'System commands are not available in browser Opal.',
    severity: 'error'
  },
  {
    pattern: /\b`[^`]+`/g,
    message: 'Backtick command execution is not available in Opal. In Opal, backticks are used for native JavaScript code.',
    severity: 'warning'
  },
  // Socket and networking
  {
    pattern: /\b(TCPSocket|TCPServer|UDPSocket|UNIXSocket|Socket)\b/g,
    message: 'Socket operations are not available in browser Opal. Use fetch or WebSocket instead.',
    severity: 'error'
  },
  // ObjectSpace and GC
  {
    pattern: /\bObjectSpace\.(each_object|count_objects|define_finalizer|garbage_collect)\b/g,
    message: 'ObjectSpace is limited in Opal. Most operations are not available.',
    severity: 'warning'
  },
  {
    pattern: /\bGC\.(start|enable|disable|stress)\b/g,
    message: 'GC control is not available in Opal. JavaScript handles garbage collection automatically.',
    severity: 'warning'
  },
  // Encoding issues
  {
    pattern: /\bEncoding\.(find|list|compatible\?|default_external|default_internal)\b/g,
    message: 'Encoding operations are limited in Opal. JavaScript uses UTF-16 internally.',
    severity: 'warning'
  },
  {
    pattern: /\.force_encoding\s*\(/g,
    message: 'force_encoding is not fully supported in Opal.',
    severity: 'warning'
  },
  // Reflection and metaprogramming limitations
  {
    pattern: /\bTracePoint\.(new|trace|stat)\b/g,
    message: 'TracePoint is not available in Opal.',
    severity: 'error'
  },
  {
    pattern: /\bBinding\.(of_caller)\b/g,
    message: 'Binding.of_caller is not available in Opal.',
    severity: 'error'
  },
  // Native extensions
  {
    pattern: /\brequire\s+['"]ffi['"]/g,
    message: 'FFI (Foreign Function Interface) is not available in Opal.',
    severity: 'error'
  },
  // C extensions
  {
    pattern: /\brequire\s+['"](nokogiri|mysql2|pg|sqlite3|redis|eventmachine)['"]/g,
    message: 'This gem uses native C extensions and is not available in Opal.',
    severity: 'error'
  },
  // refinements (partial support)
  {
    pattern: /\busing\s+\w+/g,
    message: 'Refinements have limited support in Opal.',
    severity: 'warning'
  },
  // Fiber (partial support)
  {
    pattern: /\bFiber\.(new|yield|current)\b/g,
    message: 'Fiber has limited support in Opal. Consider using PromiseV2 for async operations.',
    severity: 'warning'
  }
];

// Additional patterns for helpful hints
const HINT_PATTERNS: Array<{
  pattern: RegExp;
  message: string;
}> = [
  {
    pattern: /\brequire\s+['"]json['"]/g,
    message: 'Tip: In Opal, use Native JSON object directly: `JSON.parse(str)` or `JSON.stringify(obj)`'
  },
  {
    pattern: /\bTime\.now\b/g,
    message: 'Tip: Time.now works in Opal but returns a wrapped JavaScript Date object.'
  },
  {
    pattern: /\bRandom\.(rand|new|seed)\b/g,
    message: 'Tip: Random works in Opal using JavaScript Math.random() internally.'
  }
];

let diagnosticCollection: vscode.DiagnosticCollection;
let statusBarItem: vscode.StatusBarItem;
let diagnosticsEnabled = true;

export function activate(context: vscode.ExtensionContext) {
  console.log('Opal Vite extension is now active');

  // Create diagnostic collection
  diagnosticCollection = vscode.languages.createDiagnosticCollection('opal');
  context.subscriptions.push(diagnosticCollection);

  // Create status bar item
  statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
  statusBarItem.command = 'opalVite.toggleDiagnostics';
  updateStatusBar();
  statusBarItem.show();
  context.subscriptions.push(statusBarItem);

  // Register commands
  context.subscriptions.push(
    vscode.commands.registerCommand('opalVite.toggleDiagnostics', toggleDiagnostics),
    vscode.commands.registerCommand('opalVite.compileFile', compileCurrentFile)
  );

  // Get configuration
  const config = vscode.workspace.getConfiguration('opalVite');
  diagnosticsEnabled = config.get('enableDiagnostics', true);

  // Watch for document changes
  context.subscriptions.push(
    vscode.workspace.onDidOpenTextDocument(analyzeDocument),
    vscode.workspace.onDidChangeTextDocument(event => analyzeDocument(event.document)),
    vscode.workspace.onDidCloseTextDocument(doc => diagnosticCollection.delete(doc.uri))
  );

  // Watch for configuration changes
  context.subscriptions.push(
    vscode.workspace.onDidChangeConfiguration(event => {
      if (event.affectsConfiguration('opalVite')) {
        const config = vscode.workspace.getConfiguration('opalVite');
        diagnosticsEnabled = config.get('enableDiagnostics', true);
        updateStatusBar();

        // Re-analyze all open documents
        vscode.workspace.textDocuments.forEach(analyzeDocument);
      }
    })
  );

  // Analyze all already open documents
  vscode.workspace.textDocuments.forEach(analyzeDocument);
}

function isOpalFile(document: vscode.TextDocument): boolean {
  // Check if it's a Ruby file
  if (document.languageId !== 'ruby' && document.languageId !== 'opal') {
    return false;
  }

  const config = vscode.workspace.getConfiguration('opalVite');
  const autoDetect = config.get('autoDetectOpalFiles', true);

  if (!autoDetect) {
    return document.languageId === 'opal';
  }

  // Check if file is in app/opal directory
  const filePath = document.uri.fsPath;
  if (filePath.includes('/app/opal/') || filePath.includes('\\app\\opal\\')) {
    return true;
  }

  // Check for Opal-specific patterns in the file
  const text = document.getText();
  const opalPatterns = [
    /`[^`]+`/, // Native JS blocks
    /\bNative\b/,
    /\bJS::/,
    /\bPromiseV2\b/,
    /\bOpalVite::/,
    /require\s+['"]opal/
  ];

  return opalPatterns.some(pattern => pattern.test(text));
}

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
  const config = vscode.workspace.getConfiguration('opalVite');
  const severityMap: Record<string, vscode.DiagnosticSeverity> = {
    error: vscode.DiagnosticSeverity.Error,
    warning: vscode.DiagnosticSeverity.Warning,
    information: vscode.DiagnosticSeverity.Information,
    hint: vscode.DiagnosticSeverity.Hint
  };

  const configuredSeverity = config.get<string>('diagnosticSeverity', 'warning');

  // Check for incompatible patterns
  for (const { pattern, message, severity } of INCOMPATIBLE_PATTERNS) {
    // Reset regex state
    pattern.lastIndex = 0;

    let match;
    while ((match = pattern.exec(text)) !== null) {
      const startPos = document.positionAt(match.index);
      const endPos = document.positionAt(match.index + match[0].length);
      const range = new vscode.Range(startPos, endPos);

      // Use configured severity or pattern-specific severity
      const diagnosticSeverity = severity === 'error'
        ? vscode.DiagnosticSeverity.Error
        : severityMap[configuredSeverity] || vscode.DiagnosticSeverity.Warning;

      const diagnostic = new vscode.Diagnostic(
        range,
        `[Opal] ${message}`,
        diagnosticSeverity
      );
      diagnostic.source = 'Opal Vite';
      diagnostic.code = 'opal-incompatible';
      diagnostics.push(diagnostic);
    }
  }

  // Check for hint patterns
  for (const { pattern, message } of HINT_PATTERNS) {
    pattern.lastIndex = 0;

    let match;
    while ((match = pattern.exec(text)) !== null) {
      const startPos = document.positionAt(match.index);
      const endPos = document.positionAt(match.index + match[0].length);
      const range = new vscode.Range(startPos, endPos);

      const diagnostic = new vscode.Diagnostic(
        range,
        message,
        vscode.DiagnosticSeverity.Hint
      );
      diagnostic.source = 'Opal Vite';
      diagnostic.code = 'opal-hint';
      diagnostics.push(diagnostic);
    }
  }

  diagnosticCollection.set(document.uri, diagnostics);
}

function toggleDiagnostics(): void {
  diagnosticsEnabled = !diagnosticsEnabled;

  const config = vscode.workspace.getConfiguration('opalVite');
  config.update('enableDiagnostics', diagnosticsEnabled, vscode.ConfigurationTarget.Workspace);

  updateStatusBar();

  if (!diagnosticsEnabled) {
    diagnosticCollection.clear();
  } else {
    vscode.workspace.textDocuments.forEach(analyzeDocument);
  }

  vscode.window.showInformationMessage(
    `Opal diagnostics ${diagnosticsEnabled ? 'enabled' : 'disabled'}`
  );
}

function updateStatusBar(): void {
  if (diagnosticsEnabled) {
    statusBarItem.text = '$(ruby) Opal';
    statusBarItem.tooltip = 'Opal Vite: Diagnostics enabled (click to toggle)';
  } else {
    statusBarItem.text = '$(ruby) Opal (off)';
    statusBarItem.tooltip = 'Opal Vite: Diagnostics disabled (click to toggle)';
  }
}

async function compileCurrentFile(): Promise<void> {
  const editor = vscode.window.activeTextEditor;
  if (!editor) {
    vscode.window.showWarningMessage('No file is currently open');
    return;
  }

  const document = editor.document;
  if (!isOpalFile(document)) {
    vscode.window.showWarningMessage('Current file is not an Opal file');
    return;
  }

  // Save the file first
  await document.save();

  const terminal = vscode.window.createTerminal('Opal Vite');
  terminal.show();
  terminal.sendText(`bundle exec opal -c "${document.uri.fsPath}"`);
}

export function deactivate() {
  if (diagnosticCollection) {
    diagnosticCollection.dispose();
  }
  if (statusBarItem) {
    statusBarItem.dispose();
  }
}
