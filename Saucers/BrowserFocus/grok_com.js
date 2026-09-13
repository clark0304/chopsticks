(function () {
    var el = document.querySelector('[contenteditable=true],[role=textbox]');
    if (el) {
        el.focus();
        console.log('Grok, Focus OK!');
        return true;
    }
    return false;
})();
