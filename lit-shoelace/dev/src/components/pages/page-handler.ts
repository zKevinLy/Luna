import { html } from 'lit';
import { Styles } from './styles/page-handler-styles';
import { LunaBasePage } from '../../.base-elements/luna-base-page';
import { GridStyles } from './styles/page-grid-styles';

export * from './home';
export * from './anime';
export * from '../nav/nav-bar';

export class PageHandler extends LunaBasePage {
  static properties = {
    PageName: { type:String },
  };

  constructor() {
    super();
  }

  async connectedCallback() {
    super.connectedCallback()
  }

  render() {
    var activePageHtml = html`<luna-home></luna-home>`
    const activePage = this.getContext("activePage")
    console.log("current Active", activePage?.context)
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
        <nav-bar class="row-start-1 row-span-9 col-start-1 col-span-1"></nav-bar>
        ${activePageHtml}
      </div>

    `;
  }

}

PageHandler.styles = [Styles, GridStyles];
customElements.define('page-handler', PageHandler);
