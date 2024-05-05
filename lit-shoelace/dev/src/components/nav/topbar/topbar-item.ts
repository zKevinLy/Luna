import { html } from 'lit';
import { Styles } from './styles/topbar-item-styles';
import { BaseStyles } from '../../../.base-elements/styles/luna-base-component-styles';
import { LunaBaseComponent } from '../../../.base-elements/luna-base-component';

export class TopbarItem extends LunaBaseComponent {
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
      <sl-button class="topbar-item ${this.ItemName}">
        <sl-icon name=${this.SLIcon}></sl-icon> 
        ${this.ItemName}
      </sl-button>
    `
  }

}

TopbarItem.styles = [BaseStyles, Styles];
customElements.define('topbar-item', TopbarItem);
