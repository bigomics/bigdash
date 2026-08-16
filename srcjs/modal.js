import 'jquery';

// Modals declared inside a tab cannot lay themselves out correctly.
//
// bigTabItem() carries `content-visibility: auto` (scss/modules/_tabs.scss),
// which turns on layout, style and paint containment. Paint containment makes
// the element a containing block for `position: fixed` descendants and clips
// them to its padding box -- so a Bootstrap modal declared inside a tab, as
// PlotModuleUI() and TableModuleUI() do, is laid out against the tab instead
// of the viewport and cropped by it. The dialog appears part-hidden under the
// backdrop with its close button out of reach.
//
// Lift the containment on that one tab while a modal inside it is open, and
// put it back afterwards. The tab is on screen at the time, so the rendering
// the containment would have saved is not wanted anyway; every other tab keeps
// it, which is what lets the browser skip off-screen boards.
//
// Deliberately NOT done by moving the modal to <body>: reparenting during
// `show.bs.modal` interrupts Bootstrap's fade transition (the node moves
// between `display:block` and the `.show` class being added), so the dialog
// never appears at all. It also disturbs Shiny's own showModal(), whose markup
// lives in #shiny-modal-wrapper and is removed wholesale on close.
//
// Modals outside any tab -- Shiny's showModal(), the sign-in dialog, the
// welcome page -- match nothing here and are left completely alone.

const HELD = '_bigdashModalHeld'; // how many modals are open in this tab
const PREV = '_bigdashModalPrevCV'; // inline content-visibility to restore

export const handleModals = () => {
  $(document).on('show.bs.modal', '.modal', function () {
    const tab = this.closest('.big-tab');
    if (!tab) return;
    // Counted, so two modals open in one tab do not restore it too early.
    if (tab[HELD]) {
      tab[HELD] += 1;
      return;
    }
    tab[HELD] = 1;
    tab[PREV] = tab.style.contentVisibility;
    tab.style.contentVisibility = 'visible';
  });

  $(document).on('hidden.bs.modal', '.modal', function () {
    const tab = this.closest('.big-tab');
    if (!tab || !tab[HELD]) return;
    tab[HELD] -= 1;
    if (tab[HELD] > 0) return;
    delete tab[HELD];
    tab.style.contentVisibility = tab[PREV] || '';
    delete tab[PREV];
  });
};
