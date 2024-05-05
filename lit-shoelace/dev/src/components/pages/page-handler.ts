import { html } from 'lit';
import { Styles } from './styles/page-handler-styles';
import { LunaBasePage } from '../../.base-elements/luna-base-page';
import { GridStyles } from './styles/page-grid-styles';

export * from './home';
export * from './anime';
export * from '../nav/sidebar/sidebar-items';
export * from '../nav/topbar/topbar-items';

export class PageHandler extends LunaBasePage {
  static properties = {
    PageName: { type:String },
  };

  constructor() {
    super();
  }

  async connectedCallback() {
    super.connectedCallback()
    this.addEventListener("context-updated", () => this.requestUpdate())
  }

  render() {
    var activePageHtml = html`<luna-home></luna-home>`
    const activePage = this.getContext("activePage")
    switch (activePage?.toLowerCase()){
      case "home":
        activePageHtml = html`<luna-home></luna-home>`
        break;
      case "anime":
        activePageHtml = html`<luna-anime></luna-anime>`
        break;
      default:
        activePageHtml = html`<luna-home></luna-home>`
        break;
    }
    return html`
      <div class="container">
        <sidebar-items class="nav-bar row-start-1 row-span-9 col-start-1 col-span-1"></sidebar-items>
        <topbar-items class="nav-bar row-start-1 row-span-1 col-start-2 col-span-9"></topbar-items>
        ${activePageHtml}
      </div>

    `;
  }

}

PageHandler.styles = [Styles, GridStyles];
customElements.define('page-handler', PageHandler);
