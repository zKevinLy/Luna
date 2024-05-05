import axios, { AxiosResponse } from 'axios';

interface RequestOptions {
    params?: any;
    data?: any;
}

export class APIClient {
    private baseURL: string;

    constructor(baseURL: string) {
        this.baseURL = baseURL;
    }

    async get(endpoint: string, options?: RequestOptions): Promise<any> {
        const url = `${this.baseURL}/${endpoint}`;
        const response: AxiosResponse = await axios.get(url, { params: options?.params });
        return response.data;
    }

    async post(endpoint: string, options?: RequestOptions): Promise<any> {
        const url = `${this.baseURL}/${endpoint}`;
        const response: AxiosResponse = await axios.post(url, options?.data);
        return response.data;
    }

    async update(endpoint: string, options?: RequestOptions): Promise<any> {
        const url = `${this.baseURL}/${endpoint}`;
        const response: AxiosResponse = await axios.put(url, options?.data);
        return response.data;
    }

    async delete(endpoint: string): Promise<boolean> {
        const url = `${this.baseURL}/${endpoint}`;
        const response: AxiosResponse = await axios.delete(url);
        return response.status === 204;
    }
}

