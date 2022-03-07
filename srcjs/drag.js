import 'shiny';
import {Swappable, Plugins} from '@shopify/draggable';

export const handleDrag = () => {
  const containerSelector = '.draggable-container';
  const containers = document.querySelectorAll(containerSelector);

  if (containers.length === 0) {
    return;
  }

  let swap = new Swappable(containers, {
    draggable: '.draggable-item',
    mirror: {
      appendTo: containerSelector,
      constrainDimensions: true,
    },
    plugins: [Plugins.ResizeMirror],
  });

  swap.on('swappable:stop', (e) => {
    setTimeout(() => {
      $(e.data.dragEvent.data.sourceContainer).trigger('change');
    }, 50);
  });

  var dragInput = new Shiny.InputBinding();

  $.extend(dragInput, {
    find: function(scope) {
      return $(scope).find('.draggable-container');
    },
    getValue: function(el) {
      let data = [];
      $(el)
        .find('.draggable-item')
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
          .insertBefore(`#${value[i]}`)
      }
    },
    receiveMessage: function(el, value){
      this.setValue(el, value);
    },
    subscribe: function (el, callback) {
      $(el).on('change.draggable-container', () => {
        callback(true);
      })
    },
    unsubscribe: function(el) {
      $(el).off('.draggable-container');
    },
  });

  Shiny.inputBindings.register(dragInput, 'bigui.drag'); 
}