import { html } from 'lit';
import { Styles } from '../styles/page-styles';
import { BaseStyles } from '../../../.base-elements/styles/luna-base-page-styles';
import { LunaBasePage } from '../../../.base-elements/luna-base-page';
import { GridStyles } from '../styles/page-grid-styles';

export class LunaPageMore extends LunaBasePage {
    static properties = {
        PageName: {type: String , state:true},
    };
    
    constructor() {
        super();
        this.PageName = "More"
    }
    async connectedCallback() {
        super.connectedCallback()
    }
    render() {
        return html`<p>More</p>`
    }
}
LunaPageMore.styles = [BaseStyles, Styles, GridStyles];
customElements.define('luna-more', LunaPageMore);
