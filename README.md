# Luna
All-in-one application for consuming all forms of media.
**Currently using typescript web application as a proof-of-concept**

This project itself is meant to be exported to all platforms including: 
* Windows, linux, android, ios, macos, etc..
    * **The application itself can (and will) change to a different language to support this**


THE IDEA:
* Components are to be created individually, allowing for the reuse and flexibility of the components
    * for example: Buttons. While simple to implement in theory, may have icons and descriptions associated with them. 
    * This should be created as it's own custom element, and receive it's context/data from it's parent element
    * **This level of abstraction is key, since it allows for these elements to be reused if we were to create another site**
    * For the current proof of concept - 
        * there's a .base-elements folder which essentially drives the design of the other components, and is what every other component is extended from
        * This gives us a single endpoint for accessing context
        * Nav components are the navigation parts of the application
        * cards are the visual cards the user will see
        * Pages - each individual page is created separately and is responsible for displaying only their own content. 
            * Any interactions that happen with elements within each page will be handled with each page class, since each media content is different
        * The page-handler is responsible for handling the interaction between each MAJOR page and provides them context 
* Along that note, context should be provided from a single source and passed to it's children via inheritance, so we don't have individual components directly accessing specific data

* Providers:
    * Each source will have it's own Provider that extends a base Provider class that has the Name of the provider, the content it's providing, and any other suitable properties for a base class. 
    * The Providers will essentially be the class responsible for interacting with the individual sites/ endpoints responsible for "providing" the content we need, such as the number of episodes in a season of a show, or chapters of a book
    * Currently looking at https://github.com/consumet/consumet.ts for the main source of Content description (this doesn't provide the actual video for an anime, just descriptions and cover images)
    * For actual retrieval of the video for a particular site, we'll need to develop a sort of "scraper" that looks at a particular URL and determines the base video URL and retrieve only that video.
TODO:
Find a suitable language to support all platforms
Literally everything described above ;)

Notable starting points:
https://lit.dev/docs/v1/getting-started/
https://lit.dev/docs/tools/starter-kits/#next-steps
npm install @shoelace-style/shoelace
npm i --save-dev @web/dev-server
npm run serve