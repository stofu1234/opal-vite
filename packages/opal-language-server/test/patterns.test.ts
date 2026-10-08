import { describe, it, expect } from 'vitest';
import {
  loadPatterns,
  getIncompatiblePatterns,
  getHintPatterns,
  getCategories,
  compilePattern,
  getPatternsByCategory,
  getPatternsBySeverity
} from '../src/patterns';

describe('patterns', () => {
  it('loads the shared pattern data', () => {
    const data = loadPatterns();
    expect(data.version).toBeTruthy();
    expect(getIncompatiblePatterns().length).toBeGreaterThan(0);
    expect(Array.isArray(getHintPatterns())).toBe(true);
    expect(Object.keys(getCategories()).length).toBeGreaterThan(0);
  });

  it('has unique ids and a known category for every pattern', () => {
    const patterns = getIncompatiblePatterns();
    const ids = patterns.map(p => p.id);
    expect(new Set(ids).size).toBe(ids.length);
    const categories = getCategories();
    for (const p of patterns) {
      expect(categories).toHaveProperty(p.category);
    }
  });

  it('every pattern compiles to a RegExp', () => {
    for (const p of [...getIncompatiblePatterns(), ...getHintPatterns()]) {
      expect(() => compilePattern(p.pattern)).not.toThrow();
    }
  });

  it('detects Thread usage', () => {
    const thread = getIncompatiblePatterns().find(p => p.id === 'thread-new');
    expect(thread).toBeDefined();
    const re = compilePattern(thread!.pattern);
    expect(re.test('Thread.new { work }')).toBe(true);
    expect(re.test('MyThread.new')).toBe(false);
  });

  it('filters by category and severity', () => {
    const threading = getPatternsByCategory('threading');
    expect(threading.length).toBeGreaterThan(0);
    expect(threading.every(p => p.category === 'threading')).toBe(true);
    const errors = getPatternsBySeverity('error');
    expect(errors.length).toBeGreaterThan(0);
    expect(errors.every(p => p.severity === 'error')).toBe(true);
  });
});
