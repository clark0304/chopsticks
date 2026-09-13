(function () {
    var el = document.querySelector('[contenteditable=true]');
    if (el) {
        el.focus();
        console.log('Immersivetranslate, Focus OK!');
        return true;
    }
    return false;
})();
