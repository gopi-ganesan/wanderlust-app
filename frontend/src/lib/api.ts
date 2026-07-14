const API_BASE_URL = import.meta.env.VITE_API_PATH || 'http://localhost:5000';

export function apiUrl(path: string): string {
  return `${API_BASE_URL}${path}`;
}
