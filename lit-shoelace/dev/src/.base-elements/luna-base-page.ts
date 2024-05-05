import { BaseStyles } from './styles/luna-base-page-styles';
import { LunaBaseComponent } from './luna-base-component';

export class LunaBasePage extends LunaBaseComponent {
  static properties = {
    PageName: { type: String },
  };
  constructor() {
    super();
  }
  connectedCallback() {
    super.connectedCallback();
  }
  PageName = "home"; 
}

LunaBasePage.styles = [BaseStyles];

