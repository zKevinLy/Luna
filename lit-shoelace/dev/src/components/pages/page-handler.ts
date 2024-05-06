import { html } from 'lit';
import { Styles } from './styles/page-handler-styles';
import { LunaBasePage } from '../../.base-elements/luna-base-page';
import { GridStyles } from './styles/page-grid-styles';

export * from './nav/home';
export * from './nav/favorites';
export * from './nav/browse';
export * from './nav/history';
export * from './nav/more';

export * from './arts/anime';
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
      case "favorites":
        activePageHtml = html`<luna-favorites></luna-favorites>`
        break;
      case "browse":
        activePageHtml = html`<luna-browse></luna-browse>`
        break;
      case "history":
        activePageHtml = html`<luna-history></luna-history>`
        break;
      case "more":
        activePageHtml = html`<luna-more></luna-more>`
        break;
      default:
        activePageHtml = html`<luna-home></luna-home>`
        break;
    }
    return html`
      <div class="container flex flex-col md:flex-row">
          <!-- Main Content -->
          <div class="content">
            ${activePageHtml}
          </div>
          <!-- Sidebar -->
          <div class="side-bar">
              <sidebar-items class="side-bar"></sidebar-items>
          </div>
      </div>
    `;
  }

}

PageHandler.styles = [Styles, GridStyles];
customElements.define('page-handler', PageHandler);
