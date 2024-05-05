import { css } from 'lit';

export const Styles = css`
.container {
    display: grid;
    height: 100vh;
    width: 100vw;
    grid-template-columns: repeat(9, 1fr); 
    grid-template-rows: repeat(9, 1fr);
}
`;
