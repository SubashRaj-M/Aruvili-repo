import { io } from 'socket.io-client'

export function initSocket() {
	// Use environment variable if available, otherwise use current host
	let baseUrl = import.meta.env.VITE_FRAPPE_API_URL || window.location.origin
	let host = new URL(baseUrl).hostname
	let siteName = window.site_name || host
	let protocol = baseUrl.startsWith('https') ? 'https' : 'http'
	let port = ''
	
	// Only add port if it's explicitly in the URL and not standard ports
	try {
		const url = new URL(baseUrl)
		if (url.port && url.port !== '80' && url.port !== '443') {
			port = `:${url.port}`
		}
	} catch (e) {
		// If URL parsing fails, fall back to original logic
		port = window.location.port ? `:${window.location.port}` : ''
	}
	
	let url = `${protocol}://${host}${port}/${siteName}`

	let socket = io(url, {
		withCredentials: true,
		reconnectionAttempts: 5,
	})
	return socket
}
