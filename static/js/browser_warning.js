function evilBrowser() {
  return (navigator.appName == "Microsoft Internet Explorer" || ! window.addEventListener);
}

function checkBrowser(message) {
  if (evilBrowser()) {
    document.getElementById("layout_warning").innerHTML += '<div class="slot_warning">' + message + '</div>' ;
  }
}
