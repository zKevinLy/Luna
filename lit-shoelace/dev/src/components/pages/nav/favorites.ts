import { html } from 'lit';
import { Styles } from '../styles/page-styles';
import { BaseStyles } from '../../../.base-elements/styles/luna-base-page-styles';
import { LunaBasePage } from '../../../.base-elements/luna-base-page';
import { GridStyles } from '../styles/page-grid-styles';
import { LunaCards } from '../../cards/cards';

export class LunaPageFavorites extends LunaBasePage {
    static properties = {
        PageName: {type: String , state:true},
    };
    
    constructor() {
        super();
        this.PageName = "Favorites"
    }
    async connectedCallback() {
        super.connectedCallback()
    }
    render() {
        return html`
        <topbar-items PageName="${this.PageName}" class="top-bar"></topbar-items>
        <luna-cards></luna-cards>
        `
    }
}
LunaPageFavorites.styles = [BaseStyles, Styles, GridStyles];
customElements.define('luna-favorites', LunaPageFavorites);
