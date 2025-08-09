(function(){
  const el = document.querySelector('div#app > uni-app:nth-child(1) > uni-page:nth-child(1) > uni-page-wrapper:nth-child(1) > uni-page-body:nth-child(1) > uni-view:nth-child(1) > uni-view:nth-child(3) > uni-view:nth-child(1) > uni-view:nth-child(1) > uni-swiper:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > uni-swiper-item:nth-child(1) > uni-view:nth-child(1)');
  if(!el) return;

  function fireEvent(type, props) {
    try {
      const evt = new props.constructor(type, props.options);
      el.dispatchEvent(evt);
    } catch(e) {
      console.error("Event error:", e);
    }
  }

  function makeTouch(x, y) {
    try {
      return new Touch({
        identifier: Date.now(),
        target: el,
        clientX: x,
        clientY: y,
        radiusX: 2.5,
        radiusY: 2.5,
        rotationAngle: 0,
        force: 1
      });
    } catch(e) {
      return { identifier: Date.now(), target: el, clientX: x, clientY: y };
    }
  }

  function clickTask() {
    const rect = el.getBoundingClientRect();
    const x = rect.left + rect.width/2;
    const y = rect.top + rect.height/2;
    const touchObj = makeTouch(x, y);

    fireEvent('pointerdown', {
      constructor: PointerEvent,
      options: {bubbles:true,cancelable:true,clientX:x,clientY:y,pointerId:1,pointerType:'touch'}
    });

    fireEvent('touchstart', {
      constructor: TouchEvent,
      options: {bubbles:true,cancelable:true,touches:[touchObj],targetTouches:[touchObj],changedTouches:[touchObj]}
    });

    fireEvent('touchend', {
      constructor: TouchEvent,
      options: {bubbles:true,cancelable:true,touches:[],targetTouches:[],changedTouches:[touchObj]}
    });

    fireEvent('pointerup', {
      constructor: PointerEvent,
      options: {bubbles:true,cancelable:true,clientX:x,clientY:y,pointerId:1,pointerType:'touch'}
    });

    fireEvent('click', {
      constructor: MouseEvent,
      options: {bubbles:true,cancelable:true,clientX:x,clientY:y}
    });
  }
  for (let i = 0; i < 10; i++) {
    setInterval(clickTask, 500);
  }
})();