import { LitElement, html } from 'lit';
import { Styles } from './styles/topbar-items-styles';
import { LunaBaseComponent } from '../../../.base-elements/luna-base-component';
import { BaseStyles } from '../../../.base-elements/styles/luna-base-component-styles';
import { TopbarItem } from './topbar-item';

export class TopbarItems extends LunaBaseComponent {
  static properties = {
  };

  constructor() {
    super();
  }

  async connectedCallback() {
    super.connectedCallback()
    this.addEventListener("context-updated", () => this.requestUpdate())

  }

  render() {
    return html`
      <div class="topbar-items">      
        <topbar-item ItemName="Search" SLIcon="search" @click="${(e) => this.PageSelection(e)}"></topbar-item>
      </div>
    `
  }

  PageSelection(e){
    this.setContext("activePage", e.target.ItemName)
  }
}

TopbarItems.styles = [BaseStyles, Styles];
customElements.define('topbar-items', TopbarItems);
