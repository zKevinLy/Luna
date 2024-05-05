import { LunaBaseProvider } from '../../../src/.base-elements/luna-base-provider';

export class AnimeProvider extends LunaBaseProvider {
    static properties = {
        ProviderName: { type: String },
        ProviderBaseUrl: { type: String },
    };
    
    constructor() {
        super();
        this.ProviderName = "testing"
        this.ProviderBaseUrl = "http://localhost:3000"
        this.getPopular();
    }

    getPopular() {

    }
}