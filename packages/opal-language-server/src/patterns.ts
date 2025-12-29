import { readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export interface IncompatiblePattern {
  id: string;
  category: string;
  pattern: string;
  message: string;
  severity: 'error' | 'warning' | 'information' | 'hint';
  documentation?: string;
  note?: string;
}

export interface HintPattern {
  id: string;
  pattern: string;
  message: string;
}

export interface PatternCategory {
  name: string;
  description: string;
}

export interface PatternsData {
  version: string;
  description: string;
  patterns: IncompatiblePattern[];
  hints: HintPattern[];
  categories: Record<string, PatternCategory>;
}

let cachedPatterns: PatternsData | null = null;

export function loadPatterns(): PatternsData {
  if (cachedPatterns) {
    return cachedPatterns;
  }

  const dataPath = join(__dirname, '..', 'data', 'incompatible-patterns.json');
  const data = readFileSync(dataPath, 'utf-8');
  cachedPatterns = JSON.parse(data) as PatternsData;
  return cachedPatterns;
}

export function getIncompatiblePatterns(): IncompatiblePattern[] {
  return loadPatterns().patterns;
}

export function getHintPatterns(): HintPattern[] {
  return loadPatterns().hints;
}

export function getCategories(): Record<string, PatternCategory> {
  return loadPatterns().categories;
}

export function compilePattern(pattern: string): RegExp {
  return new RegExp(pattern, 'g');
}

export function getPatternsByCategory(category: string): IncompatiblePattern[] {
  return getIncompatiblePatterns().filter(p => p.category === category);
}

export function getPatternsBySeverity(severity: IncompatiblePattern['severity']): IncompatiblePattern[] {
  return getIncompatiblePatterns().filter(p => p.severity === severity);
}
