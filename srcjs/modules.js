import 'jquery';

// Helpers for PlotModuleUI/TableModuleUI. All three are called from inline
// onclick attributes or from shinyjs::runjs, so they must be global.

// Copy the text of every .plotmodule-info block in the open info popover.
const copyPlotModuleInfo = () => {
    var elements = document.getElementsByClassName('popover-body')[0].children[0].children;
    var textToCopy = '';
    for (var i = 0; i < elements.length; i++) {
        if (elements[i].className === "plotmodule-info") {
            textToCopy += elements[i].innerText + '\n';
        }
    }
    var tempInput = document.createElement('textarea');
    tempInput.value = textToCopy.trim();
    document.body.appendChild(tempInput);
    tempInput.select();
    document.execCommand('copy');
    document.body.removeChild(tempInput);
}

// Flash a checkmark on a button to confirm an action.
const addTick = (buttonId) => {
  var button = document.getElementById(buttonId);
  var originalText = button.innerHTML;
  if (!originalText.includes('✓')) {
    button.innerHTML = originalText + '<span class="tick">✓</span>';
    button.classList.add('show-tick');
    setTimeout(function() {
      button.classList.remove('show-tick');
      setTimeout(function() {
        button.innerHTML = originalText;
      }, 500); // Match this duration with CSS transition duration
    }, 1000);
  }
}

// Dismiss a DropdownMenu popover on an outside click.
//
// Both helpers below are called from an inline onClick attribute
// (DropdownMenu(), R/dropdown-menu.R), so they run again on *every* click of
// every info/options/download button -- not once per button. Binding straight
// through therefore accumulated one permanent handler per click for the whole
// session, and each of those walked the entire document for '.popover' on
// every click anywhere in the app, SVG interiors included. Both are now
// idempotent, and one shared handler serves every trigger.
const dismissibleIds = new Set();
let dismissBound = false;

// Whether the click landed inside an open popover. closest() walks up from the
// target -- tree depth, a few dozen steps -- where the '.popover' query it
// replaces walked every node in the document.
const insidePopover = (target) => !!(target && target.closest && target.closest('.popover'));

const dismissPopovers = (e) => {
  if (insidePopover(e.target)) return;
  dismissibleIds.forEach((id) => {
    const trigger = document.getElementById(id);
    // Gone: its module was re-rendered, and DropdownMenu() mints a fresh id
    // each time, so drop it rather than let the set grow all session.
    if (!trigger) {
      dismissibleIds.delete(id);
      return;
    }
    // Bootstrap points the trigger at its popover while that popover is open,
    // so this is the cheap "is there anything to hide" test.
    if (!trigger.getAttribute('aria-describedby')) return;
    if (trigger === e.target || trigger.contains(e.target)) return;
    $(trigger).popover('hide');
  });
}

const makePopoverDismissible = (id) => {
  dismissibleIds.add(id);
  if (dismissBound) return;
  dismissBound = true;
  $(document).on('click.bigdash-popover', dismissPopovers);
}

// Mark the trigger button active for as long as its popover is open.
const addActionOnPopoverChange = (popoverId) => {
  const el = document.getElementById(popoverId);
  if (!el || el.dataset.bdPopoverActive) return;
  el.dataset.bdPopoverActive = '1';

  $(el).on('hidden.bs.popover', function () {
    $(this).removeClass('btn-active');
  });
  $(el).on('shown.bs.popover', function () {
    $(this).addClass('btn-active');
  });
}

export const handleModules = () => {
  window.copyPlotModuleInfo = copyPlotModuleInfo;
  window.addTick = addTick;
  window.makePopoverDismissible = makePopoverDismissible;
  window.addActionOnPopoverChange = addActionOnPopoverChange;
}
