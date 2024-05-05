import { LunaBaseComponent } from '../../src/.base-elements/luna-base-component';

export class ContextProvider extends LunaBaseComponent {
    static properties = {
        PageName: {type: String , state:true},
    };
    
    constructor() {
        super();
    }
    async connectedCallback() {
        super.connectedCallback()
    }

}