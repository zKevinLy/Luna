import { html } from 'lit';
import { Styles } from '../styles/page-styles';
import { BaseStyles } from '../../../.base-elements/styles/luna-base-page-styles';
import { LunaBasePage } from '../../../.base-elements/luna-base-page';
import { GridStyles } from '../styles/page-grid-styles';

export class LunaPageHistory extends LunaBasePage {
    static properties = {
        PageName: {type: String , state:true},
    };
    
    constructor() {
        super();
        this.PageName = "History"
    }
    async connectedCallback() {
        super.connectedCallback()
    }
    render() {
        return html`<p>History</p>`
    }
}
LunaPageHistory.styles = [BaseStyles, Styles, GridStyles];
customElements.define('luna-history', LunaPageHistory);
