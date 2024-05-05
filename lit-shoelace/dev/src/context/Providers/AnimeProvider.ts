import { LunaBaseProvider } from '../../../src/.base-elements/luna-base-provider';
import { ANIME } from "@consumet/extensions"

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
        async () => {
            // Create a new instance of the Gogoanime provider
            const gogoanime = new ANIME.Gogoanime();
            // Search for an anime. In this case, "One Piece"
            const results = await gogoanime.search("One Piece");
            // print the results
            console.log(results);
        };
    }
}