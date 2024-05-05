import { LitElement, html } from 'lit';
import { Styles } from './styles/nav-bar-styles';
import { LunaBaseComponent } from '../../.base-elements/luna-base-component';
import { BaseStyles } from '../../.base-elements/styles/luna-base-component-styles';
import { NavItem } from './nav-item';

export class NavBar extends LunaBaseComponent {
  static properties = {
  };

  constructor() {
    super();
  }

  async connectedCallback() {
    super.connectedCallback()
    this.addEventListener("context-updated", (e) => this.requestUpdate())

  }

  render() {
    return html`
      <div class="nav-bar">
        <nav-item ItemName="Home" SLIcon="house" @click="${(e) => this.PageSelection(e)}"></nav-item>
        <nav-item ItemName="Anime" SLIcon="film" @click="${(e) => this.PageSelection(e)}"></nav-item>
      </div>
    `
  }

  PageSelection(e){
    this.context.activePage = e.target.ItemName
    this.setContext("context", this.context)
  }
}

NavBar.styles = [BaseStyles, Styles];
customElements.define('nav-bar', NavBar);
