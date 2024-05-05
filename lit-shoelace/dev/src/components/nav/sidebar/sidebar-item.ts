import { html } from 'lit';
import { Styles } from './styles/sidebar-item-styles';
import { BaseStyles } from '../../../.base-elements/styles/luna-base-component-styles';
import { LunaBaseComponent } from '../../../.base-elements/luna-base-component';

export class SidebarItem extends LunaBaseComponent {
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
      <sl-button class="sidebar-item ${this.ItemName}" size="small">
        <sl-icon name=${this.SLIcon}></sl-icon> 
        <p>${this.ItemName}</p>
      </sl-button>
    `
  }

}

SidebarItem.styles = [BaseStyles, Styles];
customElements.define('sidebar-item', SidebarItem);
