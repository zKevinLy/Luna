import { LitElement } from 'lit';
import { BaseStyles } from './styles/luna-base-component-styles';

export class LunaBaseComponent extends LitElement {
  static properties = {
  };
  constructor() {
    super();
  }

  context = {
    activePage:""
  }

  connectedCallback() {
    super.connectedCallback();
    this.addEventListener("context-updated", () => this.requestUpdate())
  }
  
  setContext(property, value){
    console.log(property, value)
    localStorage.setItem(property, value);
    this.triggerRender()
  }

  getContext(property){
    console.log(localStorage.getItem(property))
    return (localStorage.getItem(property) as any);
  }

  triggerRender(){
    this.dispatchEvent(new CustomEvent('context-updated', { 
    }));
  }
}

LunaBaseComponent.styles = [BaseStyles];
