# vite-plugin-opal Tests

This directory contains tests for the vite-plugin-opal package.

## Test Structure

- `plugin.test.ts` - Plugin integration tests
- `compiler.test.ts` - Opal compiler tests
- `resolver.test.ts` - Module resolver tests

## Running Tests

```bash
pnpm test
```

## Test Requirements

### Plugin Tests
Plugin integration tests (`plugin.test.ts`) run without additional requirements and test:
- Plugin initialization
- Hook definitions
- Option validation
- Type exports

### Compiler & Resolver Tests
Compiler and resolver tests (`compiler.test.ts`, `resolver.test.ts`) require a properly configured Ruby environment:

**Prerequisites:**
- Ruby 3.0+ installed
- Bundler installed
- opal-vite gem available

**Setup:**
```bash
# From the project root
cd gems/opal-vite
bundle install

# Build and install the gem locally
gem build opal-vite.gemspec
gem install opal-vite-*.gem

# Or add to Gemfile and bundle install
```

### Running Specific Tests

```bash
# Run only plugin tests
pnpm test plugin

# Run only resolver tests
pnpm test resolver

# Run only compiler tests (requires gem setup)
pnpm test compiler
```

## Test Coverage

Current test coverage includes:

**Plugin Tests:**
- ✅ Plugin creation with default/custom options
- ✅ Hook presence verification
- ✅ Virtual module resolution
- ✅ HTML transformation
- ✅ Option validation

**Resolver Tests:**
- ✅ Absolute path resolution
- ✅ Relative path resolution
- ✅ Load path resolution
- ✅ Extension handling (.rb)
- ✅ Nested path resolution
- ✅ Cache behavior
- ✅ Edge cases (special characters, case sensitivity)

**Compiler Tests:**
- ✅ Basic Ruby compilation
- ✅ Complex Ruby syntax (classes, methods)
- ✅ Source map generation
- ✅ Compilation caching
- ✅ Cache invalidation
- ✅ Require statement handling
- ✅ Opal runtime retrieval
- ✅ Error handling (invalid syntax)

## Writing New Tests

When adding new tests, follow these guidelines:

1. **Use descriptive test names** - "it compiles simple Ruby code" vs "it works"
2. **Test one thing per test** - Each test should verify a single behavior
3. **Use beforeAll/afterAll** - For setup/teardown that can be shared
4. **Clean up resources** - Remove temporary files/directories in afterAll
5. **Mock when appropriate** - Use mocks for external dependencies
6. **Document requirements** - Add comments if test needs special setup

### Example Test Structure

```typescript
import { describe, it, expect, beforeAll, afterAll } from 'vitest'

describe('MyFeature', () => {
  beforeAll(() => {
    // Setup
  })

  afterAll(() => {
    // Cleanup
  })

  describe('specific functionality', () => {
    it('does what it should', () => {
      // Arrange
      const input = 'test'

      // Act
      const result = myFunction(input)

      // Assert
      expect(result).toBe('expected')
    })
  })
})
```

## Continuous Integration

Tests run automatically on:
- Pull requests
- Commits to main branch
- Release builds

## Troubleshooting

### "cannot load such file -- opal-vite"

This error occurs when running compiler tests without the opal-vite gem installed. Solutions:

1. Install the gem globally (see Test Requirements above)
2. Skip compiler tests: `pnpm test -- --exclude compiler`
3. Set up a complete development environment as documented in the main README

### "Module not found" errors

Ensure you've run `pnpm install` in the package directory:

```bash
cd packages/vite-plugin-opal
pnpm install
```

### TypeScript errors

If you see TypeScript compilation errors, rebuild the package:

```bash
pnpm build
```

## Contributing

When contributing new features:

1. Write tests for new functionality
2. Ensure existing tests still pass
3. Update this README if adding new test files
4. Maintain or improve test coverage

Happy testing! 🧪
