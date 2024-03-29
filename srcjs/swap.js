import 'shiny';
import {Swappable, Plugins} from '@shopify/draggable';

export const handleSwap = () => {
  const containerSelector = '.swappable-container';
  const containers = document.querySelectorAll(containerSelector);

  if (containers.length === 0) {
    return;
  }

  let swap = new Swappable(containers, {
    draggable: '.swappable-item',
    mirror: {
      appendTo: containerSelector,
      constrainDimensions: true,
    },
    plugins: [Plugins.ResizeMirror],
  });

  swap.on('swappable:stop', (e) => {
    setTimeout(() => {
      console.log(e.data.dragEvent.data.sourceContainer);
      $(e.data.dragEvent.data.sourceContainer).trigger('change');
      $(e.data.dragEvent.data.sourceContainer).find('.shiny-plot-output').trigger('resize');
    }, 50);
  });

  var swapInput = new Shiny.InputBinding();

  $.extend(swapInput, {
    find: function(scope) {
      return $(scope).find('.swappable-container');
    },
    getValue: function(el) {
      let data = [];
      $(el)
        .find('.swappable-item')
        .each((index, item) => {
          data.push($(item).attr('id'));
        });

      return data;
    },
    setValue: function(el, value) {
      // we need at least two items to sort
      if(value.length < 2)
        return;

      for(let i = 0; i < value.length; i++) {
        $(el)
          .find(`#${value[i-1]}`)
          .insertBefore(`#${value[i]}`);
      }
    },
    receiveMessage: function(el, value){
      this.setValue(el, value);
    },
    subscribe: function (el, callback) {
      $(el).on('change.swappable-container', () => {
        callback(true);
      })
    },
    unsubscribe: function(el) {
      $(el).off('.swappable-container');
    },
  });

  Shiny.inputBindings.register(swapInput, 'bigdash.swap'); 
}
