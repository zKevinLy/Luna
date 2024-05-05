import { css } from 'lit';

export const Styles = css`
.sidebar-item,
.sidebar-item::part(base){
    padding:0px;
    margin:0px;
    width:100%;
    height:100%;
    background: rgba(30, 30, 30, 0); /* Transparent*/
    border-color: rgba(30, 30, 30, 0); /* Transparent*/;
    color:white;
    border-radius:25px;
}

.sidebar-item {
    display: flex;
    flex-direction: row;
}

p{
    padding: 0px
}
`;
