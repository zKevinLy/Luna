import { LitElement } from 'lit';
import { BaseStyles } from './styles/luna-base-component-styles';

export abstract class LunaBaseComponent extends LitElement {
  static styles = [BaseStyles];

  static properties = {
    PageName: {type: String , state:true},
  };

  PageName = ""; 

  constructor() {
    super();
  }
}
