import { html } from 'lit';
import { Styles } from './styles/home-styles';
import { BaseStyles } from '../../.base-elements/styles/luna-base-page-styles';
import { LunaBasePage } from '../../.base-elements/luna-base-page';

export class LunaHome extends LunaBasePage {
    static styles = [BaseStyles, Styles];

    static properties = {
        PageName: {type: String , state:true},
    };
    
    constructor() {
        super();
        this.PageName = "Home"
    }

    render() {
        return html`<p>dasd</p>`
    }
}
customElements.define('luna-home', LunaHome);
