import { html } from 'lit';
import { Styles } from './styles/cards-styles';
import { BaseStyles } from '../../.base-elements/styles/luna-base-component-styles';
import { LunaBaseComponent } from '../../.base-elements/luna-base-component';
import { LunaCard } from './card';
export class LunaCards extends LunaBaseComponent {
  static properties = {
    ItemName: {type: String },
    SLIcon: {type: String },
  };
  
  ItemName = "default-name";
  SLIcon = "hourglass-bottom";

  constructor() {
    super();
  }

  async connectedCallback() {
    super.connectedCallback()
  }

  render() {
    const pageItems = this.getContext("pageItems")
    return html`
      <div class="content-items">
        <luna-card ItemName="Home" SLIcon="house" @click="${(e) => this.CardSelection(e)}"></luna-card>
        <luna-card ItemName="Favorites" SLIcon="heart" @click="${(e) => this.CardSelection(e)}"></luna-card>
        <luna-card ItemName="Browse" SLIcon="search" @click="${(e) => this.CardSelection(e)}"></luna-card>
        <luna-card ItemName="History" SLIcon="clock-history" @click="${(e) => this.CardSelection(e)}"></luna-card>
        <luna-card ItemName="More" SLIcon="three-dots" @click="${(e) => this.CardSelection(e)}"></luna-card>
      </div>
    `
  }

  CardSelection(e){
    return e;
  }
}

LunaCards.styles = [BaseStyles, Styles];
customElements.define('luna-cards', LunaCards);
