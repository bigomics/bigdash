import 'jquery';

// Modals declared inside a tab cannot lay themselves out correctly.
//
// bigTabItem() carries `content-visibility: auto` (scss/modules/_tabs.scss),
// which turns on layout, style and paint containment. Paint containment makes
// the element a containing block for `position: fixed` descendants and clips
// them to its padding box -- so a Bootstrap modal declared inside a tab, as
// PlotModuleUI() and TableModuleUI() do, is positioned relative to that tab
// instead of the viewport and gets cropped by it. Visually: the dialog appears
// part-hidden under the backdrop with its close button out of reach.
//
// Rather than give up the containment (it is what lets the browser skip
// rendering off-screen tabs), move the modal to <body> while it is open so it
// is laid out against the viewport, and put it back when it closes. Restoring
// matters: the modal belongs to the tab's DOM, and leaving it parked on <body>
// would leak it if the tab is later removed via removeUI().
//
// Moving a node does not disturb Shiny: input/output bindings are held on the
// elements themselves and ids are unchanged, so nothing needs re-binding.

const ORIGIN = '_bigdashModalOrigin';

export const handleModals = () => {
  $(document).on('show.bs.modal', '.modal', function () {
    if (this.parentElement === document.body) return;
    // Remember where it came from: the placeholder keeps the slot so the modal
    // returns to the same position among its siblings.
    const placeholder = document.createComment('bigdash-modal');
    this.parentElement.insertBefore(placeholder, this);
    this[ORIGIN] = placeholder;
    document.body.appendChild(this);
  });

  $(document).on('hidden.bs.modal', '.modal', function () {
    const placeholder = this[ORIGIN];
    if (!placeholder) return;
    delete this[ORIGIN];
    // The tab may have been removed while the modal was open.
    if (placeholder.parentElement) {
      placeholder.parentElement.replaceChild(this, placeholder);
    } else if (this.parentElement === document.body) {
      this.remove();
    }
  });
};
