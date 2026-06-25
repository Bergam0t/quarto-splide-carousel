-- splide-carousel.lua
--
-- Reusable Quarto/Pandoc Lua filter that turns a plain div full of markdown
-- images into an interactive Splide.js carousel with GLightbox full-screen
-- viewing -- no hand-written HTML/JS needed in the .qmd itself, and safe to
-- use more than once per page (each carousel gets its own unique id).
--
-- USAGE
-- ------
-- ::: {.splide-carousel}
-- ![Outpatient non-attendance](impact_posters/Outpatient non attendance.png)
-- ![Stroke care simulation](impact_posters/Using Simulation to Improve Stroke Care and Reduce Costs.png){width="150px"}
-- :::

-- The markdown alt text (the bit in square brackets) becomes the caption
-- shown under each poster. Leave it blank -- ![](path.png) -- for no caption.

-- OPTIONAL DIV ATTRIBUTES (defaults match the original design)
--   interval="9000"        autoplay interval in ms
--   autoplay="false"       set to "false" to disable autoplay
--   padding="5rem"         Splide side padding
--   default-width="250px"  fallback slide width for images with no width set

-- OPTIONAL PER-IMAGE ATTRIBUTE
--   ![caption](src){width="150px"}   overrides the slide width for just that image

-- SETUP
-- ------
-- Add to your document YAML or _quarto.yml:
--   filters:
--     - splide-carousel.lua
--
-- Splide/GLightbox <script>/<link> tags, plus a local splide-carousel.css
-- (for the caption/toggle-button styling), are injected automatically --
-- once per rendered page. splide-carousel.css should sit next to this
-- filter file.

local carousel_count = 0
local resources_included = false

local function get_attr(div, key, default)
  local v = div.attr.attributes[key]
  if v == nil or v == "" then
    return default
  end
  return v
end

local function include_head_resources()
  if resources_included then
    return
  end
  resources_included = true

  -- Third-party CDN resources (Splide + GLightbox themselves)
  local head = [[
<script src="https://cdn.jsdelivr.net/npm/@splidejs/splide@4.1.4/dist/js/splide.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/glightbox/3.3.0/js/glightbox.min.js"></script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@splidejs/splide@4.1.4/dist/css/splide.min.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/glightbox/3.3.0/css/glightbox.css">
]]
  quarto.doc.include_text("in-header", head)

  -- Our own local stylesheet (caption styling, toggle button, etc).
  -- Resolved relative to this filter's own directory, and only ever
  -- included once in the rendered output regardless of how many times
  -- this function or the filter itself runs.
  quarto.doc.add_html_dependency({
    name = "splide-carousel-styles",
    version = "1.0.0",
    stylesheets = { "splide-carousel.css" }
  })
end

-- Recursively collect every Image inline inside a Div (covers plain
-- paragraphs of images, bullet lists of images, etc.)
local function collect_images(div)
  local images = {}
  pandoc.walk_block(div, {
    Image = function(img)
      table.insert(images, img)
      return img
    end
  })
  return images
end

local function build_slide(img, default_width)
  local width = img.attr.attributes["width"]
  if width == nil or width == "" then
    width = default_width
  end

  local caption = pandoc.utils.stringify(img.caption or {})

  return string.format(
    '      <li class="splide__slide" style="width: %s">\n' ..
    '        <img src="%s" alt="%s" class="glightbox">\n' ..
    '        <div class="splide_caption">%s</div>\n' ..
    '      </li>',
    width, img.src, caption, caption
  )
end

local function build_carousel(div)
  local images = collect_images(div)
  if #images == 0 then
    return nil
  end

  carousel_count = carousel_count + 1
  local id = "splide-carousel-" .. carousel_count

  local interval = get_attr(div, "interval", "9000")
  local padding = get_attr(div, "padding", "5rem")
  local default_width = get_attr(div, "default-width", "250px")
  local autoplay_attr = get_attr(div, "autoplay", "true")
  local autoplay_js = (autoplay_attr == "false") and "false" or "'play'"

  local slides = {}
  for _, img in ipairs(images) do
    table.insert(slides, build_slide(img, default_width))
  end

  local html = string.format([[
<section id="%s" class="splide splide-carousel" aria-label="Beautiful Images">
  <div class="splide__optional-button-container">
    <button class="splide__toggle" type="button">
      <a class="splide__toggle__play"><i class="fa-solid fa-play"></i><span style="padding-left: 10px;">Resume Slideshow</span></a>
      <a class="splide__toggle__pause"><i class="fa-solid fa-pause"></i><span style="padding-left: 10px;">Pause Slideshow</span></a>
    </button>
  </div>
  <div class="splide__track">
    <ul class="splide__list">
%s
    </ul>
  </div>
</section>
<script>
document.addEventListener('DOMContentLoaded', function () {
  var splideInstance = new Splide('#%s', {
    type: 'loop',
    padding: '%s',
    autoplay: %s,
    interval: %s,
    focus: 'center',
    pauseOnHover: true,
    pauseOnFocus: false,
    resetProgress: false
  }).mount();

  var lightboxInstance = GLightbox({
    selector: '#%s .glightbox',
    touchNavigation: true,
    loop: true
  });

  splideInstance.on('moved', function () {
    lightboxInstance.reload();
  });
});
</script>
]], id, table.concat(slides, "\n"), id, padding, autoplay_js, interval, id)

  include_head_resources()

  return pandoc.RawBlock("html", html)
end

-- For non-HTML output (PDF/Word/etc) just render the posters as a normal
-- sequence of images rather than dropping them silently.
local function fallback_for_non_html(div)
  local images = collect_images(div)
  local blocks = {}
  for _, img in ipairs(images) do
    table.insert(blocks, pandoc.Para({ img }))
  end
  return blocks
end

local function SplideCarousel(div)
  if not div.classes:includes("splide-carousel") then
    return nil
  end

  if not quarto.doc.is_format("html") then
    return fallback_for_non_html(div)
  end

  return build_carousel(div)
end

return {
  { Div = SplideCarousel }
}
