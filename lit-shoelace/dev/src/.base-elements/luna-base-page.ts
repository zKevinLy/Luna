import { LitElement } from 'lit';
import { BaseStyles } from './styles/luna-base-page-styles';

export class LunaBasePage extends LitElement {
  static styles = [BaseStyles];

  static properties = {
    PageName: {type: String , state:true},
  };

  PageName = ""; 

  constructor() {
    super();
  }
}
