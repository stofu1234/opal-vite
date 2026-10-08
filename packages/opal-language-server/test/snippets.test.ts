import { describe, it, expect } from 'vitest';
import { InsertTextFormat, CompletionItemKind } from 'vscode-languageserver';
import {
  getSnippets,
  getSnippetCategories,
  getSnippetsByCategory,
  snippetToVSCode,
  convertAllSnippetsToVSCode,
  snippetToLSPCompletionItem,
  getAllCompletionItems
} from '../src/snippets';

describe('snippets', () => {
  it('loads snippets with prefix and body', () => {
    const snippets = getSnippets();
    expect(snippets.length).toBeGreaterThan(0);
    for (const s of snippets) {
      expect(s.prefix.length).toBeGreaterThan(0);
      expect(s.body.length).toBeGreaterThan(0);
    }
  });

  it('filters by category', () => {
    const categories = Object.keys(getSnippetCategories());
    expect(categories.length).toBeGreaterThan(0);
    const some = getSnippetsByCategory(categories[0]);
    expect(some.every(s => s.category === categories[0])).toBe(true);
    expect(getSnippetsByCategory('no-such-category')).toEqual([]);
  });

  it('converts to the VSCode snippet format', () => {
    const [first] = getSnippets();
    expect(snippetToVSCode(first)).toEqual({
      prefix: first.prefix,
      body: first.body,
      description: first.description
    });
    const all = convertAllSnippetsToVSCode();
    expect(Object.keys(all).length).toBeGreaterThan(0);
    expect(all[first.name]).toBeDefined();
  });

  it('converts to LSP completion items, one per prefix', () => {
    const [first] = getSnippets();
    const items = snippetToLSPCompletionItem(first);
    expect(items.map(i => i.label)).toEqual(first.prefix);
    for (const item of items) {
      expect(item.kind).toBe(CompletionItemKind.Snippet);
      expect(item.insertTextFormat).toBe(InsertTextFormat.Snippet);
      expect(item.insertText).toBe(first.body.join('\n'));
    }
    const total = getSnippets().reduce((n, s) => n + s.prefix.length, 0);
    expect(getAllCompletionItems().length).toBe(total);
  });
});
