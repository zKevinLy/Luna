import { css } from 'lit';

export const Styles = css`
.topbar-item,
.topbar-item::part(base){
    padding:0px;
    margin:0px;
    width:100%;
    height:100%;
    background: rgba(30, 30, 30, 0); /* Transparent*/
    border-color: rgba(30, 30, 30, 0); /* Transparent*/;
    color:white;
    border-radius:25px;
    
}

p {
    padding: 10px 0px 0px 10px;
    margin:0px;
    font-size:1.5em;
    color:gray;
    font-family: var(--sl-input-font-family);
}
`;
