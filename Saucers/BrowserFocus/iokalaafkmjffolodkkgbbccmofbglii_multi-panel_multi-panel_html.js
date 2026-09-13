(function () {
    var el = document.querySelector('#unified-input');
    if (el) {
        el.focus();
        console.log('Multi Panel, Focus OK!');
        return true;
    }
    return false;
})();
