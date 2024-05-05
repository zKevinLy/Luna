import { html } from 'lit';
import { Styles } from './styles/topbar-item-styles';
import { BaseStyles } from '../../../.base-elements/styles/luna-base-component-styles';
import { LunaBaseComponent } from '../../../.base-elements/luna-base-component';

export class TopbarItem extends LunaBaseComponent {
  static properties = {
    ItemToolTip: {type: String },
    ItemName: {type: String },
    SLIcon: {type: String },
  };

  ItemToolTip = "default-description";
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
    <sl-tooltip content="${this.ItemToolTip}">
      <sl-button class="topbar-item ${this.ItemName}">
        <sl-icon name=${this.SLIcon}></sl-icon> 
      </sl-button>
    </sl-tooltip>
    `
  }

}

TopbarItem.styles = [BaseStyles, Styles];
customElements.define('topbar-item', TopbarItem);
