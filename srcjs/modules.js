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
const makePopoverDismissible = (id) => {
  $(document).click(function (e) {
    var popover = $('#' + id);
    if (!popover.is(e.target) && popover.has(e.target).length === 0 && $('.popover').has(e.target).length === 0) {
      popover.popover('hide');
    }
  });
}

// Mark the trigger button active for as long as its popover is open.
const addActionOnPopoverChange = (popoverId) => {
  $('#' + popoverId).on('hidden.bs.popover', function () {
    $(this).removeClass('btn-active');
  });
  $('#' + popoverId).on('shown.bs.popover', function () {
    $(this).addClass('btn-active');
  });
}

export const handleModules = () => {
  window.copyPlotModuleInfo = copyPlotModuleInfo;
  window.addTick = addTick;
  window.makePopoverDismissible = makePopoverDismissible;
  window.addActionOnPopoverChange = addActionOnPopoverChange;
}
