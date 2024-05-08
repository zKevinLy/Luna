import { LitElement, html } from 'lit';
import { Styles } from './styles/topbar-items-styles';
import { LunaBaseComponent } from '../../../.base-elements/luna-base-component';
import { BaseStyles } from '../../../.base-elements/styles/luna-base-component-styles';
import { TopbarItem } from './topbar-item';

export class TopbarItems extends LunaBaseComponent {
  static properties = {
    PageName: {type: String},
  };
  PageName
  constructor() {
    super();
  }

  async connectedCallback() {
    super.connectedCallback()
    this.addEventListener("context-updated", () => this.requestUpdate())
  }

  render() {
    return html`
      <div class="topbar-items" ItemName=""> 
        <topbar-item ItemName="${this.PageName}"></topbar-item>
        <div class="options">
          <topbar-item ItemToolTip="Search" ItemName="Search" SLIcon="search" @click="${(e) => this.FilterSelection(e)}"></topbar-item>
          <topbar-item ItemToolTip="Filter" ItemName="Filter" SLIcon="filter" @click="${(e) => this.FilterSelection(e)}"></topbar-item>
        </div>
      </div>
    `
  }

  FilterSelection(e){
    // Search
    return e;
  }
}

TopbarItems.styles = [BaseStyles, Styles];
customElements.define('topbar-items', TopbarItems);
