import { css } from 'lit';

export const Styles = css`
.content-items {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); /* Change 100px to your desired minimum width */
    grid-auto-rows: minmax(200px, auto); /* Change 100px to your desired minimum height */
    grid-gap: 0; /* Remove any gap between grid items */
}

`;
