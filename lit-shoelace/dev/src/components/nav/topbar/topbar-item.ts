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

  ItemToolTip;
  ItemName;
  SLIcon;

  constructor() {
    super();
  }

  async connectedCallback() {
    super.connectedCallback()
  }

  render() {
    var topBarHtml = html``
    // If there's a tooltip, it's a button, if not it's a title
    if (this.ItemToolTip === null || this.ItemToolTip === undefined){
      topBarHtml = html`<p>${this.ItemName}<p>`
    } else {
      topBarHtml = html`
        <sl-tooltip content="${this.ItemToolTip}">
          <sl-button class="topbar-item ${this.ItemName}" size = "large">
            <sl-icon name=${this.SLIcon}></sl-icon>
          </sl-button>
        </sl-tooltip>
      `
    }

    return html`
      ${topBarHtml}
    `
  }

}

TopbarItem.styles = [BaseStyles, Styles];
customElements.define('topbar-item', TopbarItem);
