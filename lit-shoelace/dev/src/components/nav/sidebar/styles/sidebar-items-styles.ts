import { css } from 'lit';

export const Styles = css`
.sidebar-items{
    display: flex;
    flex-direction: row;
    justify-content: space-evenly;
    height:100%;
    width:100%;
    overflow-y: auto; 
}

@media (min-width: 768px) {
    .sidebar-items {
        flex-direction: column; /* For medium and larger screens */
        overflow-y: visible; /* Reset scrolling for larger screens */
        justify-content: flex-start;
    }
}

/* For WebKit browsers (Chrome, Safari, etc.) */
.sidebar-items::-webkit-scrollbar {
    width: 10px; /* Width of the scrollbar */
}

.sidebar-items::-webkit-scrollbar-track {
    background: #f1f1f1; /* Color of the track */
}

.sidebar-items::-webkit-scrollbar-thumb {
    background: #888; /* Color of the thumb */
    border-radius: 5px; /* Rounded corners */
}

.sidebar-items::-webkit-scrollbar-thumb:hover {
    background: #555; /* Color of the thumb on hover */
}

`;
