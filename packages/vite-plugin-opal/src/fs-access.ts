import type { ViteDevServer } from 'vite'
import { normalizePath } from 'vite'

const isWindows = process.platform === 'win32'
// Windows and macOS file systems are case-insensitive by default (as in Vite)
const isCaseInsensitiveFS = isWindows || process.platform === 'darwin'
const windowsDriveRE = /^[A-Z]:/i

type DenyGlob = (file: string) => boolean

/**
 * The deny-glob matcher of the running server. Vite 5 keeps it on the server
 * (`server._fsDenyGlob`), Vite 6 and later on the resolved config
 * (`config.fsDenyGlob`).
 */
function getDenyGlob(server: ViteDevServer): DenyGlob | null {
  const anyServer = server as unknown as {
    _fsDenyGlob?: unknown
    config?: { fsDenyGlob?: unknown }
  }
  if (typeof anyServer.config?.fsDenyGlob === 'function') {
    return anyServer.config.fsDenyGlob as DenyGlob
  }
  if (typeof anyServer._fsDenyGlob === 'function') {
    return anyServer._fsDenyGlob as DenyGlob
  }
  return null
}

function isInDirectory(dir: string, file: string): boolean {
  const d = dir.endsWith('/') ? dir : `${dir}/`
  if (file === dir || file.startsWith(d)) return true
  return (
    isCaseInsensitiveFS &&
    (file.toLowerCase() === dir.toLowerCase() || file.toLowerCase().startsWith(d.toLowerCase()))
  )
}

/**
 * Whether the dev server may serve `file` (`server.fs.strict`, `fs.deny` and
 * `fs.allow`). Equivalent to Vite's `isFileServingAllowed`, but reads the
 * running server instead of calling the `vite` package this plugin happens to
 * resolve: that function's signature and the server properties it reads differ
 * between Vite majors, so a mismatch made every request fail with
 * `server._fsDenyGlob is not a function`.
 *
 * Fails closed: when the deny-glob matcher cannot be found (an unknown Vite
 * version), the file is not allowed.
 */
export function isFileServingAllowedByServer(file: string, server: ViteDevServer): boolean {
  const config = server.config
  const fs = config?.server?.fs
  if (!fs) return false
  if (!fs.strict) return true

  const filePath = normalizePath(file)
  if (isWindows && filePath.includes('~')) return false
  const withoutDrive = isWindows && windowsDriveRE.test(filePath) ? filePath.slice(2) : filePath
  if (withoutDrive.includes(':')) return false

  const denyGlob = getDenyGlob(server)
  if (!denyGlob) return false
  if (denyGlob(filePath.endsWith('/') ? filePath.slice(0, -1) : filePath)) return false

  const anyServer = server as unknown as { _safeModulePaths?: Set<string> }
  const safe =
    (config as unknown as { safeModulePaths?: Set<string> }).safeModulePaths ??
    anyServer._safeModulePaths
  if (safe?.has(filePath)) return true

  return (fs.allow ?? []).some((dir) => isInDirectory(normalizePath(dir), filePath))
}
