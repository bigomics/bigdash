# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

`bigdash` is an R package that provides a Shiny dashboard layout and theme for BigOmics. It combines R UI components with compiled JavaScript (webpack) and SCSS-compiled CSS.

## Build Commands

The build pipeline has two compiled artifacts that must stay in sync with source:

```bash
# Full build: SCSS → CSS, JS → bundle, then install
make install

# Steps individually:
make sass      # Compiles scss/main.scss → inst/assets/style.min.css
make packer    # Runs packer::bundle_prod() → inst/assets/index.js (via webpack)
make document  # Runs devtools::document() to regenerate NAMESPACE and man/
make check     # Runs devtools::check() (R CMD check)
```

For JS development with live reload:
```bash
npm run watch   # webpack watch mode
```

After editing SCSS or JS source, you must rebuild before the R package picks up the changes — the `inst/assets/` compiled files are what the package ships.

## Architecture

### R → JS/CSS boundary

`R/deps.R` declares an `htmlDependency` that injects `inst/assets/index.js` and `inst/assets/style.min.css` into every `bigPage()`. These compiled files are the only JS/CSS the package serves.

### Tab navigation system

Tabs are not standard Shiny `tabPanel`s. The system works as follows:
- `bigTabItem(name, ...)` renders as `div.big-tab.d-none[data-name=name]` — hidden by default
- `sidebarItem(title, target)` and `sidebarMenuItem(text, target)` emit elements with `class="tab-trigger"` and `data-target=target`
- `srcjs/sidebar.js` listens for clicks on `.tab-trigger`, calls `toggleTabs(target)` which shows the matching `.big-tab` and hides all others
- Active tab name is pushed to Shiny as `input$nav` via `Shiny.setInputValue('nav', name)`
- `navbarTab` and `navbarDropdownTab` also use `class="tab-trigger"` so clicking them switches tabs the same way

### Settings panel

`settings(...)` creates a right (or left) sidebar that is hidden by default. `tabSettings(...)` inside a `bigTabItem` contains per-tab settings content. When a tab is activated, `sidebar.js` finds the matching `.tab-settings` div and moves its content into `#settings-content`.

### Swappable (drag-and-drop)

`swappable(inputId)` + `swappableItem(inputId)` creates drag-and-drop reorderable containers powered by `@shopify/draggable`. The container registers as a Shiny input binding (`bigdash.swap`) — `input$<swappable_id>` returns a character vector of `swappableItem` `inputId`s in their current DOM order. `update_swappable(id, order)` reorders them from the server side.

### Sidebar help

`sidebarHelp(sidebarTabHelp(target, title, text), ...)` serialises contextual help to a `<script type="application/json">` tag. On `shiny:connected`, `sidebar.js` reads this JSON and shows the relevant help section whenever a tab is activated.

### SCSS structure

`scss/main.scss` imports all modules from `scss/modules/`. Each module maps to a UI component (navbar, sidebar, tabs, settings, etc.). Compiled output goes to `inst/assets/style.min.css`.

### Webpack config

`webpack.common.js` reads all config from `srcjs/config/*.json`. Entry point is `srcjs/index.js`, output goes to `inst/assets/`. `srcjs/index.js` imports and initialises all JS modules on `$(function(){...})`.
