import { LitElement, html } from 'lit';
import { Styles } from './styles/sidebar-items-styles';
import { LunaBaseComponent } from '../../../.base-elements/luna-base-component';
import { BaseStyles } from '../../../.base-elements/styles/luna-base-component-styles';
import { SidebarItem } from './sidebar-item';

export class SidebarItems extends LunaBaseComponent {
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
      <div class="sidebar-items">
        <sidebar-item ItemName="Home" SLIcon="house" @click="${(e) => this.PageSelection(e)}"></sidebar-item>
        <sidebar-item ItemName="Anime" SLIcon="film" @click="${(e) => this.PageSelection(e)}"></sidebar-item>
        <sidebar-item ItemName="Manga" SLIcon="book-half" @click="${(e) => this.PageSelection(e)}"></sidebar-item>
        <sidebar-item ItemName="Novel" SLIcon="book" @click="${(e) => this.PageSelection(e)}"></sidebar-item>
        <sidebar-item ItemName="KDrama" SLIcon="suit-heart" @click="${(e) => this.PageSelection(e)}"></sidebar-item>
        <sidebar-item ItemName="Movies" SLIcon="camera-reels-fill" @click="${(e) => this.PageSelection(e)}"></sidebar-item>
        <sidebar-item ItemName="TV" SLIcon="tv-fill" @click="${(e) => this.PageSelection(e)}"></sidebar-item>
        <sidebar-item ItemName="More" SLIcon="three-dots" @click="${(e) => this.PageSelection(e)}"></sidebar-item>
      </div>
    `
  }

  PageSelection(e){
    this.setContext("activePage", e.target.ItemName)
  }
}

SidebarItems.styles = [BaseStyles, Styles];
customElements.define('sidebar-items', SidebarItems);
