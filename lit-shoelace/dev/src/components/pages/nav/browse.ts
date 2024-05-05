import { html } from 'lit';
import { Styles } from '../styles/page-styles';
import { BaseStyles } from '../../../.base-elements/styles/luna-base-page-styles';
import { LunaBasePage } from '../../../.base-elements/luna-base-page';
import { GridStyles } from '../styles/page-grid-styles';

export class LunaPageBrowse extends LunaBasePage {
    static properties = {
        PageName: {type: String , state:true},
    };
    
    constructor() {
        super();
        this.PageName = "Browse"
    }
    async connectedCallback() {
        super.connectedCallback()
    }
    render() {
        return html`<p>Browse</p>`
    }
}
LunaPageBrowse.styles = [BaseStyles, Styles, GridStyles];
customElements.define('luna-browse', LunaPageBrowse);
