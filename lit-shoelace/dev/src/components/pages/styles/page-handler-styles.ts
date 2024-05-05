import { css } from 'lit';

export const Styles = css`
.container {
    height: 100vh;
    width: 100vw;
}

.side-bar {
    background: #1e1e1e;
}

.top-bar {
    background: #1e1e1e;
}

.container {
    display: flex;
}

@media (max-width: 768px) {
    .container {
        flex-direction: column;
    }

    .side-bar {
        display: flex;
        flex-direction: row;
    }

    .content {
        order: 2;
    }

    .top-bar {
        order: 3;
    }
}

`;
