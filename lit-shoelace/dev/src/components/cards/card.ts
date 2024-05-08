import { html } from 'lit';
import { Styles } from './styles/card-styles';
import { BaseStyles } from '../../.base-elements/styles/luna-base-component-styles';
import { LunaBaseComponent } from '../../.base-elements/luna-base-component';

export class LunaCard extends LunaBaseComponent {
  static properties = {
    ItemName: {type: String },
    SLIcon: {type: String },
  };
  
  ItemName = "default-name";
  SLIcon = "hourglass-bottom";

  constructor() {
    super();
  }

  async connectedCallback() {
    super.connectedCallback()
  }

  render() {
    return html`
    <sl-card class="card-image">
      <img
        slot="image"
        src="https://images.unsplash.com/photo-1547191783-94d5f8f6d8b1?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=400&q=80"
      />
    </sl-card>
    `
  }
}

LunaCard.styles = [BaseStyles, Styles];
customElements.define('luna-card', LunaCard);
