import { css } from 'lit';

export const Styles = css`
.container {
    height: 100vh;
    width: 100vw;
}

.content {
    height: 100%;
    width: 100%;
    background:black;
    color:white;
    font-family: var(--sl-input-font-family);
}

.side-bar {
    background: #1e1e1e;
}


.container {
    display: flex;
    flex-direction: column; /* For small screens, default */
}

@media (min-width: 768px) {
    .container {
        flex-direction: row; /* For medium and larger screens */
    }

    .side-bar {
        order: -1; /* Move sidebar to the left */
    }
}
`;
