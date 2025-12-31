import { readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { CompletionItem, CompletionItemKind, InsertTextFormat } from 'vscode-languageserver';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export interface Snippet {
  id: string;
  name: string;
  prefix: string[];
  description: string;
  category: string;
  body: string[];
  placeholderChoices?: Record<string, string[]>;
}

export interface SnippetCategory {
  name: string;
  description: string;
}

export interface SnippetsData {
  version: string;
  description: string;
  snippets: Snippet[];
  categories: Record<string, SnippetCategory>;
}

let cachedSnippets: SnippetsData | null = null;

export function loadSnippets(): SnippetsData {
  if (cachedSnippets) {
    return cachedSnippets;
  }

  const dataPath = join(__dirname, '..', 'data', 'snippets.json');
  const data = readFileSync(dataPath, 'utf-8');
  cachedSnippets = JSON.parse(data) as SnippetsData;
  return cachedSnippets;
}

export function getSnippets(): Snippet[] {
  return loadSnippets().snippets;
}

export function getSnippetCategories(): Record<string, SnippetCategory> {
  return loadSnippets().categories;
}

export function getSnippetsByCategory(category: string): Snippet[] {
  return getSnippets().filter(s => s.category === category);
}

export function snippetToVSCode(snippet: Snippet): Record<string, unknown> {
  return {
    prefix: snippet.prefix,
    body: snippet.body,
    description: snippet.description
  };
}

export function convertAllSnippetsToVSCode(): Record<string, Record<string, unknown>> {
  const result: Record<string, Record<string, unknown>> = {};
  for (const snippet of getSnippets()) {
    result[snippet.name] = snippetToVSCode(snippet);
  }
  return result;
}

export function snippetToLSPCompletionItem(snippet: Snippet): CompletionItem[] {
  const bodyText = snippet.body.join('\n');

  return snippet.prefix.map(prefix => ({
    label: prefix,
    kind: CompletionItemKind.Snippet,
    detail: snippet.name,
    documentation: snippet.description,
    insertText: bodyText,
    insertTextFormat: InsertTextFormat.Snippet
  }));
}

export function getAllCompletionItems(): CompletionItem[] {
  const items: CompletionItem[] = [];
  for (const snippet of getSnippets()) {
    items.push(...snippetToLSPCompletionItem(snippet));
  }
  return items;
}

export function snippetToIntelliJ(snippet: Snippet): Record<string, unknown> {
  const bodyText = snippet.body.join('\n')
    .replace(/\$\{(\d+):([^}]+)\}/g, '$$$2$')
    .replace(/\$(\d+)/g, '$$END$$');

  return {
    abbreviation: snippet.prefix[0],
    description: snippet.description,
    template: bodyText,
    context: 'Ruby'
  };
}

export function convertAllSnippetsToIntelliJ(): Record<string, unknown>[] {
  return getSnippets().map(snippetToIntelliJ);
}
