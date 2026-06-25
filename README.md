This is a small filter to allow you to create an image carousel.

The carousel uses the [splide](https://splidejs.com/) typescript library.

## Installation

You can add this extension to your project by running

```
quarto add bergam0t/quarto-splide-carousel
```

## Usage

First, you must make sure the filter is added to the list of extensions in your document header.



```yml
---
format:
  revealjs: default  # this will also work with other web-based formats, such as html
filters:
  - splide-carousel
---
```

> [!WARNING]
> Note that it is called 'splide-carousel' when added to your document - not 'quarto-splide-carousel'


> [!TIP]
> You could also do
>
> ```yml
> ---
> filters:
>   - bergam0t/splide-carousel
> ---
> ```
>
> if you have another filter extension with the same name!


### Creating carousels

To turn multiple images into a carousel, start the block with
`::: {.splide-carousel}`

and add

`:::`

at the end to finish the carousel.

e.g.

```md
::: {.splide-carousel}
![Outpatient non-attendance](impact_posters/Outpatient non attendance.png)
![Stroke care simulation](impact_posters/Using Simulation to Improve Stroke Care and Reduce Costs.png)
:::
```

The markdown alt text (the bit in square brackets) becomes the caption
shown under each poster.

Leave it blank - `![](path.png)` - for no caption.

Paths can be urls or local relative paths.


### Customisation

#### Whole Carousel

There are various attributes you can pass in when initialising the carousel div.

e.g.

  interval="9000"            autoplay interval in ms
  autoplay="false"           set to "false" to disable autoplay
  padding="5rem"             Splide side padding (overrides the preview default below)
  default-width="250px"      fallback slide width for images with no width set
  preview="false"            "true" (default) peeks at the prev/next slide either
                             side of center; "false" gives a standard one-at-a-time
                             carousel with no padding/peek
  toggle-bg-color="#222"     background colour of the play/pause toggle button --
                             overrides the default set in splide-carousel.css;
                             omit to just use the CSS default
  toggle-text-color="#000"   text/icon colour of the play/pause toggle button --
                             same override behaviour as toggle-bg-color above

## Contributing

Please take a look at our [contributor guidance](CONTRIBUTING) and [code of conduct](CODE_OF_CONDUCT)

### Generative AI use disclosure and policy

Conversion from a bit of HTML I was using in one of my websites to an actual reusable filter was aided by Claude Sonnet 4.6.

All AI-generated code has been thoroughly reviewed and tested before inclusion.

We are happy to accept AI-supported contributions to the extension, but reserve the right to reject wholly AI generated pull requests which are not felt to add value to the project.

## Alternatives

Other carousels exist!

Check out [this bootstrap carousel component](https://github.com/tomicapretto/quarto-carousel) by [Tomás Capretto](https://github.com/tomicapretto).
