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
      <sl-resize-observer>
<div class="container flex flex-col md:flex-row">
    <!-- Topbar -->
    <div class="top-bar md:order-2 md:w-full">
        <topbar-items class="top-bar"></topbar-items>
    </div>

    <!-- Main Content -->
    <div class="content md:order-3 md:w-full">
        ${activePageHtml}
    </div>

    <!-- Sidebar -->
    <div class="side-bar md:order-1 md:w-full">
        <sidebar-items class="side-bar"></sidebar-items>
    </div>
</div>

      </sl-resize-observer>
    `;
  }

}

PageHandler.styles = [Styles, GridStyles];
customElements.define('page-handler', PageHandler);
