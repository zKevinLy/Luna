import { css } from 'lit';

export const Styles = css`
.card-image::part(base){
    background: rgba(30, 30, 30, 0); /* Transparent*/;
    border-color: rgba(30, 30, 30, 0); /* Transparent*/;
    
}
.card-image::part(body) {
    height: 10px;
}
`;
