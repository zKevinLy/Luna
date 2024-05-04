import { LitElement, html } from 'lit';
import { Styles } from './styles/page-handler-styles';
import { LunaHome } from './home';

export class PageHandler extends LitElement {
  static styles = [Styles];

  static properties = {
  };
  
  constructor() {
    super();
  }

  render() {
    return html`<luna-home></luna-home>`;
  }
}
customElements.define('page-handler', PageHandler);
