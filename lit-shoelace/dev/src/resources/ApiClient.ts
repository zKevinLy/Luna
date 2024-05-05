export class APIClient {
    baseURL;

    constructor(baseURL) {
        this.baseURL = baseURL;
    }

    async get(endpoint, options) {
        const url = `${this.baseURL}/${endpoint}`;
        const response = await fetch(url + this.buildQueryString(options?.params));
        return await response.json();
    }

    async post(endpoint, options) {
        const url = `${this.baseURL}/${endpoint}`;
        const response = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(options?.data)
        });
        return await response.json();
    }

    async update(endpoint, options) {
        const url = `${this.baseURL}/${endpoint}`;
        const response = await fetch(url, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(options?.data)
        });
        return await response.json();
    }

    async delete(endpoint) {
        const url = `${this.baseURL}/${endpoint}`;
        const response = await fetch(url, { method: 'DELETE' });
        return response.status === 204;
    }

    buildQueryString(params) {
        if (!params) return '';
        const queryString = Object.keys(params)
            .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`)
            .join('&');
        return `?${queryString}`;
    }
}
