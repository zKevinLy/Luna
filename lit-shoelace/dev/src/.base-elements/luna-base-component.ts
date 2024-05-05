import { LitElement } from 'lit';
import { BaseStyles } from './styles/luna-base-component-styles';

export class LunaBaseComponent extends LitElement {
  static properties = {
  };
  constructor() {
    super();
  }

  connectedCallback() {
    super.connectedCallback();
  }
  
  setContext(property, value){
    localStorage.setItem(property, value);
    this.triggerRender()
  }

  getContext(property){
    return (localStorage.getItem(property));
  }

  triggerRender(){
    this.dispatchEvent(new CustomEvent('context-updated', { 
      bubbles:true,
      composed:true,
    }));
    this.requestUpdate();
  }
}

LunaBaseComponent.styles = [BaseStyles];
