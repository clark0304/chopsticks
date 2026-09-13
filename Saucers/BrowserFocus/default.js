(function () {
    var el = document.querySelector('textarea,[contenteditable=true],[role=textbox]');
    if (el) {
        el.focus();
        console.log('Default JS, Focus OK!');
        return true;
    }
    return false;
})();
