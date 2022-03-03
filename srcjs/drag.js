import {Swappable, Plugins} from '@shopify/draggable';

export const handleDrag = () => {
  const containerSelector = '.draggable-container';
  const containers = document.querySelectorAll(containerSelector);

  if (containers.length === 0) {
    return;
  }

  new Swappable(containers, {
    draggable: '.draggable-item',
    mirror: {
      appendTo: containerSelector,
      constrainDimensions: true,
    },
    plugins: [Plugins.ResizeMirror],
  });
}