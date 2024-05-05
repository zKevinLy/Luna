import { APIClient } from '../resources/ApiClient';

export class LunaBaseProvider extends APIClient {
  static properties = {
    ProviderName: { type: String },
    ProviderBaseUrl: { type: String },
  };
  ProviderName;
  ProviderBaseUrl;

  constructor() {
    super("https://example.com");
  }

}


