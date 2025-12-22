// Setup snabbdom as a global before any Opal code runs
// This is required because snabberb gem expects window.snabbdom to be available
import * as snabbdom from 'snabbdom'

// Set as global immediately
globalThis.snabbdom = snabbdom
window.snabbdom = snabbdom

console.log('Snabbdom setup complete:', !!window.snabbdom)
