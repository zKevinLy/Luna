import { html } from 'lit';
import { Styles } from '../styles/page-styles';
import { BaseStyles } from '../../../.base-elements/styles/luna-base-page-styles';
import { LunaBasePage } from '../../../.base-elements/luna-base-page';
import { GridStyles } from '../styles/page-grid-styles';
import { AnimeProvider } from '../../../context/Providers/AnimeProvider';


export class LunaPageAnime extends LunaBasePage {
    static properties = {
        PageName: {type: String , state:true},
    };
    
    constructor() {
        super();
        this.PageName = "Anime"
    }
    async connectedCallback() {
        super.connectedCallback()
        new AnimeProvider().getPopular();
    }
    render() {
        return html`<p>Anime</p>`
    }
}
LunaPageAnime.styles = [BaseStyles, Styles, GridStyles];
customElements.define('luna-anime', LunaPageAnime);
